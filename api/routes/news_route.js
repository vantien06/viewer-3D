const express = require('express');
const router = express.Router();
const News = require('../config/models/news_model');
const { Query } = require('mongoose');

// @route   GET /api/news

router.get('/', async (req, res) => {
    const { page = 1, limit = 10, category, keyword } = req.query;
    const query = {};

    if (category) {
        query.category = category;
    }

    if (keyword) {
        query.title = { $regex: keyword, $options: 'i' };
    }

    try {
        const news = await News.find(query)
            .sort({ publishedAt: -1 })
            .skip((page - 1) * limit)
            .limit(parseInt(limit));

        const total = await News.countDocuments(query);

        res.json({
            success: true,
            data: news,
            currentPage: parseInt(page),
            totalPages: Math.ceil(total / limit),
            totalArticles: total
        });
    }
    catch (err) { res.status(500).json({ success: false, message: err.message }); }

});

router.post('/', async (req, res) => {
    const { title, description, content, imageUrl, category } = req.body;

    try {
        const news = await News.create({
            title,
            description,
            content,
            imageUrl,
            category
        });

        res.status(201).json({ success: true, data: news });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
});

module.exports = router;