const express = require('express');
const bodyParser = require('body-parser');
const dotEnv = require('dotenv');
const connectDB = require('./config/db');
const newsRoutes = require('./routes/news_route');

dotEnv.config();

// Connect to database
connectDB();

const app = express();

app.use(bodyParser.json());

app.use('/api/news', newsRoutes);

//         enum: ['Technology', 'Health', 'Sports', 'Business', 'Entertainment', 'Science', 'World', 'Politics', 'Travel', 'Lifestyle'],
const categories = [
    { name: 'Technology', icon: 'computer' },
    { name: 'Health', icon: 'health_and_safety' },
    { name: 'Sports', icon: 'sports_soccer' },
    { name: 'Business', icon: 'business' },
    { name: 'Entertainment', icon: 'movie' },
    { name: 'Science', icon: 'science' },
    { name: 'World', icon: 'public' },
    { name: 'Politics', icon: 'gavel' },
    { name: 'Travel', icon: 'flight' },
    { name: 'Lifestyle', icon: 'style' }
];

app.get('/api/categories', (req, res) => {
    res.json({ success: true, data: categories });
});

const PORT = process.env.PORT || 4500;

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});