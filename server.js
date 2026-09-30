const http = require('http');
const https = require('https');
const url = require('url');
const zlib = require('zlib');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 8080;
const HOST = '0.0.0.0';
const TARGET_HOST = 'h5.aoneroom.com';

const MIME_TYPES = {
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.webp': 'image/webp',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.json': 'application/json',
  '.js': 'application/javascript',
  '.css': 'text/css',
  '.ico': 'image/x-icon',
  '.mp4': 'video/mp4'
};

function rewriteContent(text) {
  // Rewrite CDN domains to go through our proxy so Biznet won't block them
  const cdnDomains = [
    'https://pacdn.aoneroom.com',
    'https://pbcdn.aoneroom.com',
    'https://pbcdnw.aoneroom.com',
    'https://macdn.aoneroom.com',
    'https://h5-static.aoneroom.com'
  ];

  for (const cdn of cdnDomains) {
    text = text.split(cdn).join(`/proxy?url=${encodeURIComponent(cdn)}`);
  }

  // Rewrite main site links to relative paths
  text = text.split('https://h5.aoneroom.com').join('');

  // Inject iOS PWA tags into <head>
  if (text.includes('<head>')) {
    const pwaTags = `
<head>
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
  <meta name="apple-mobile-web-app-title" content="MovieBox">
  <link rel="apple-touch-icon" href="/icon.png">
  <link rel="manifest" href="/manifest.json">
`;
    text = text.replace('<head>', pwaTags);
  }

  return text;
}

const server = http.createServer((req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const pathname = parsedUrl.pathname;

  // 1. Serve icon.png
  if (pathname === '/icon.png') {
    const iconPath = path.join(__dirname, 'icon.png');
    if (fs.existsSync(iconPath)) {
      res.writeHead(200, {
        'Content-Type': 'image/png',
        'Cache-Control': 'public, max-age=86400'
      });
      return fs.createReadStream(iconPath).pipe(res);
    }
  }

  // 2. Serve manifest.json
  if (pathname === '/manifest.json') {
    const manifestPath = path.join(__dirname, 'manifest.json');
    if (fs.existsSync(manifestPath)) {
      res.writeHead(200, {
        'Content-Type': 'application/manifest+json',
        'Cache-Control': 'public, max-age=3600'
      });
      return fs.createReadStream(manifestPath).pipe(res);
    }
  }

  // 3. Proxy endpoint for CDNs and media
  if (pathname === '/proxy') {
    let target = parsedUrl.query.url;
    if (!target) {
      res.writeHead(400, { 'Content-Type': 'text/plain' });
      return res.end('Missing url parameter');
    }

    try {
      const targetParsed = url.parse(target);
      const isHttps = targetParsed.protocol === 'https:';
      const client = isHttps ? https : http;

      const proxyHeaders = {
        'User-Agent': req.headers['user-agent'] || 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)',
        'Referer': 'https://h5.aoneroom.com/'
      };

      if (req.headers['range']) {
        proxyHeaders['Range'] = req.headers['range'];
      }

      const proxyReq = client.request(target, {
        method: req.method,
        headers: proxyHeaders
      }, (proxyRes) => {
        const resHeaders = {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Headers': '*'
        };

        if (proxyRes.headers['content-type']) resHeaders['Content-Type'] = proxyRes.headers['content-type'];
        if (proxyRes.headers['content-length']) resHeaders['Content-Length'] = proxyRes.headers['content-length'];
        if (proxyRes.headers['content-range']) resHeaders['Content-Range'] = proxyRes.headers['content-range'];
        if (proxyRes.headers['accept-ranges']) resHeaders['Accept-Ranges'] = proxyRes.headers['accept-ranges'];
        if (proxyRes.headers['cache-control']) resHeaders['Cache-Control'] = proxyRes.headers['cache-control'];

        res.writeHead(proxyRes.statusCode, resHeaders);
        proxyRes.pipe(res);
      });

      proxyReq.on('error', (err) => {
        console.error('Proxy request error:', err.message);
        if (!res.headersSent) {
          res.writeHead(502, { 'Content-Type': 'text/plain' });
          res.end('Proxy Error: ' + err.message);
        }
      });

      return req.pipe(proxyReq);
    } catch (e) {
      res.writeHead(500, { 'Content-Type': 'text/plain' });
      return res.end('Invalid URL');
    }
  }

  // 4. Default: Proxy to h5.aoneroom.com
  const options = {
    hostname: TARGET_HOST,
    port: 443,
    path: req.url,
    method: req.method,
    headers: {
      ...req.headers,
      host: TARGET_HOST,
      'accept-encoding': 'gzip, deflate',
      'user-agent': req.headers['user-agent'] || 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)'
    }
  };

  delete options.headers['cookie'];

  const targetReq = https.request(options, (targetRes) => {
    const contentType = targetRes.headers['content-type'] || '';
    const contentEncoding = targetRes.headers['content-encoding'];
    const isText = contentType.includes('text/html') || 
                   contentType.includes('application/javascript') || 
                   contentType.includes('text/javascript') || 
                   contentType.includes('application/json');

    // If text/html or JS, decompress, rewrite URLs, and send
    if (isText) {
      let stream = targetRes;
      if (contentEncoding === 'gzip') {
        stream = targetRes.pipe(zlib.createGunzip());
      } else if (contentEncoding === 'deflate') {
        stream = targetRes.pipe(zlib.createInflate());
      }

      const chunks = [];
      stream.on('data', chunk => chunks.push(chunk));
      stream.on('end', () => {
        let body = Buffer.concat(chunks).toString('utf-8');
        body = rewriteContent(body);

        const newHeaders = { ...targetRes.headers };
        delete newHeaders['content-encoding'];
        delete newHeaders['content-length'];
        newHeaders['content-type'] = contentType;
        newHeaders['Access-Control-Allow-Origin'] = '*';

        res.writeHead(targetRes.statusCode, newHeaders);
        res.end(body);
      });

      stream.on('error', (err) => {
        console.error('Decompression error:', err);
        res.writeHead(500);
        res.end('Server Stream Error');
      });
    } else {
      // Binary (images, fonts, etc.): Pipe directly
      res.writeHead(targetRes.statusCode, targetRes.headers);
      targetRes.pipe(res);
    }
  });

  targetReq.on('error', (err) => {
    console.error('Target Request Error:', err.message);
    if (!res.headersSent) {
      res.writeHead(502, { 'Content-Type': 'text/plain' });
      res.end('Gateway Error: ' + err.message);
    }
  });

  req.pipe(targetReq);
});

server.listen(PORT, HOST, () => {
  console.log(`MovieBox Proxy Server running at:`);
  console.log(`  Local:   http://localhost:${PORT}`);
  console.log(`  Network: http://192.168.18.16:${PORT}`);
});
