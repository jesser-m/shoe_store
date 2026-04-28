const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('./models/User');
require('dotenv').config();

const ADMIN_EMAIL = 'admin@gmail.com';
const ADMIN_PASSWORD = '111111';

const seedAdmin = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('MongoDB connected');

    const existing = await User.findOne({ email: ADMIN_EMAIL });
    if (existing) {
      console.log('Admin already exists:', existing.email);
      await mongoose.disconnect();
      return;
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(ADMIN_PASSWORD, salt);

    const admin = await User.create({
      name: 'Administrateur',
      email: ADMIN_EMAIL,
      password: hashedPassword,
      displayName: 'Administrateur',
      role: 'admin',
      isActive: true,
    });

    console.log('Admin created successfully!');
    console.log('Email:', admin.email);
    console.log('Role:', admin.role);
    await mongoose.disconnect();
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
};

seedAdmin();
