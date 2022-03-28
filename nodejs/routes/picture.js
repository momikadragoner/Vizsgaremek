const express = require('express');
const multer = require('multer');
const router = express.Router();

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'uploads/product_pictures')
    },
    filename: function (req, file, cb) {
        const ext = file.mimetype.split("/")[1];
        const uniqueSuffix = Date.now() + '-' + (Math.round(Math.random() * 1E9) + '.' + ext)
        cb(null, 'product-picture' + '-' + uniqueSuffix)
    }
})

const multerFilter = (req, file, cb) => {
    if (file.mimetype.split("/")[1] === "png" || file.mimetype.split("/")[1] === "jpeg") {
        cb(null, true);
    } else {
        cb(new Error("File format not supported!"), false);
    }
};

const upload = multer({ storage: storage, fileFilter: multerFilter });

router.post('/product-picture', upload.array('pictures', 3), async (req, res, next) => {
    try {
        let links = [];
        req.files.forEach( file => {
            links.push(file.filename);
        })
        res.status(200);
        res.json(links);
        // res.json({ 'message': 'File created successfully!' });
    } catch (error) {
        res.status(300);
        res.json({ error });
    }
});

module.exports = router;