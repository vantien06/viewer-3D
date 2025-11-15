const mongoose = require('mongoose');

const newsScheme = new mongoose.Schema({
    title: {
        type: String,
        required: [true, 'Please add a title'],
    },

    description: {
        type: String,
    },

    content: {
        type: String,
    },

    imageUrl: {
        type: String,
    },

    category: {
        type: String,
        enum: ['Technology', 'Health', 'Sports', 'Business', 'Entertainment', 'Science', 'World', 'Politics', 'Travel', 'Lifestyle'],
        required: [true, 'Please add a category']
    },

    publishedAt: {
        type: Date,
        default: Date.now,
    },

    source: {
        type: String,
    },

}, { timestamps: true });

const News = mongoose.model('News', newsScheme);
module.exports = News;