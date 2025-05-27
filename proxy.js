const http = require('http');
const https = require('https');

// Define the target URL where requests will be forwarded
// localhost:3000/xrpc/app.bsky.feed.getAuthorFeed?actor=bmann.ca
// const TARGET_URL = 'https://public.api.bsky.app/xrpc/app.bsky.feed.getAuthorFeed?actor=bmann.ca'; // You can change this to your desired target
const TARGET_URL = 'https://public.api.bsky.app'; // You can change this to your desired target

const PORT = 3000;

const server = http.createServer((clientReq, clientRes) => {
    console.log(`Proxying request: ${clientReq.method} ${clientReq.url}`);

    // Parse the target URL to get host, port, and path
    const targetUrl = new URL(TARGET_URL + clientReq.url);

    const options = {
        hostname: targetUrl.hostname,
        port: targetUrl.port || (targetUrl.protocol === 'https:' ? 443 : 80),
        path: targetUrl.pathname + targetUrl.search,
        method: clientReq.method
        // headers: clientReq.headers,
    };

    // Create a request to the target server
    const proxyReq = https.request(options, (proxyRes) => {
        console.log(`Response from target: ${proxyRes.statusCode}`);

        // Set the response headers from the target server to the client
        clientRes.writeHead(proxyRes.statusCode, proxyRes.headers);

        // Pipe the response from the target server back to the client
        proxyRes.pipe(clientRes, { end: true });
    });

    // Handle errors from the proxy request
    proxyReq.on('error', (err) => {
        console.error(`Proxy request error: ${err.message}`);
        clientRes.writeHead(500, { 'Content-Type': 'text/plain' });
        clientRes.end(`Proxy error: ${err.message}`);
    });

    // Pipe the client's request body to the proxy request
    clientReq.pipe(proxyReq, { end: true });
});

server.listen(PORT, () => {
    console.log(`Proxy server listening on port ${PORT}`);
    console.log(`Forwarding requests to: ${TARGET_URL}`);
});

server.on('error', (err) => {
    if (err.code === 'EADDRINUSE') {
        console.error(`Port ${PORT} is already in use. Please choose a different port or stop the process using it.`);
    } else {
        console.error(`Server error: ${err.message}`);
    }
});

