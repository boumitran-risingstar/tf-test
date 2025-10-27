const { OAuth2Client } = require('google-auth-library');
const client = new OAuth2Client();

async function authMiddleware(req, res, next) {
  // 1. Log when middleware is triggered.
  console.log('Authorization middleware triggered for request to:', req.originalUrl);

  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    console.warn('Authorization failed: No bearer token provided.');
    return res.status(401).send('Unauthorized: No token provided');
  }

  // 2. Confirm a bearer token was found.
  console.log('Bearer token found in Authorization header.');
  const idToken = authHeader.split('Bearer ')[1];

  try {
    console.log('Verifying ID token...');
    const ticket = await client.verifyIdToken({
      idToken,
    });
    const payload = ticket.getPayload();

    // 3. Log the decoded payload.
    console.log('ID token verified successfully. Payload:', payload);

    req.user = payload;

    // 4. Confirm authorization success.
    console.log('Authorization successful. Proceeding to next middleware/route handler.');
    next();
  } catch (error) {
    console.error('Error verifying ID token:', error);
    return res.status(401).send('Unauthorized: Invalid token');
  }
}

module.exports = authMiddleware;
