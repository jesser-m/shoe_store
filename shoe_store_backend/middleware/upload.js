// Upload middleware (simplified for now)
const multer = require('multer');
const path = require('path');

// Configure storage
const storage = multer.diskStorage({
  destination: './uploads/',
  filename: (req, file, cb) => {
    cb(null, `${file.fieldname}-${Date.now()}${path.extname(file.originalname)}`);
  }
});

// Initialize upload
const upload = multer({
  storage: storage,
  limits: { fileSize: 10000000 }, // 10MB limit
  fileFilter: (req, file, cb) => {
    checkFileType(file, cb);
  }
});

// Check file type
function checkFileType(file, cb) {
  // Allowed extensions
  const filetypes = /jpeg|jpg|png|gif/;
  // Check extension
  const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
  
  // On some platforms (like Flutter Web), mimetype might be generic
  // We trust the extension if mimetype is generic or missing
  const isGenericMime = file.mimetype === 'application/octet-stream' || !file.mimetype;
  const mimetype = filetypes.test(file.mimetype) || isGenericMime;

  if (extname && mimetype) {
    return cb(null, true);
  } else {
    cb(new Error('Images Only (jpeg, jpg, png, gif)!'));
  }
}

module.exports = upload;