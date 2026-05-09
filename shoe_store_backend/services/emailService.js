const nodemailer = require('nodemailer');
require('dotenv').config();

// Create a transporter using SMTP
const transporter = nodemailer.createTransport({
  host: process.env.EMAIL_HOST || 'smtp.gmail.com',
  port: process.env.EMAIL_PORT || 587,
  secure: false, // true for 465, false for other ports
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

/**
 * Send an email
 * @param {string} to - Recipient email
 * @param {string} subject - Email subject
 * @param {string} html - Email body in HTML
 */
const sendEmail = async (to, subject, html) => {
  try {
    const mailOptions = {
      from: `"Shoe Store" <${process.env.EMAIL_FROM || 'no-reply@shoestore.com'}>`,
      to,
      subject,
      html,
    };

    const info = await transporter.sendMail(mailOptions);
    console.log('Email sent: %s', info.messageId);
    return info;
  } catch (error) {
    console.error('Error sending email:', error);
    throw error;
  }
};

/**
 * Send Order Confirmation Email
 * @param {object} order - Order object
 * @param {object} user - User object
 */
const sendOrderConfirmation = async (order, user) => {
  const itemsHtml = order.products.map(item => `
    <tr>
      <td style="padding: 10px; border-bottom: 1px solid #eee;">${item.productName || 'Produit'}</td>
      <td style="padding: 10px; border-bottom: 1px solid #eee; text-align: center;">${item.quantity}</td>
      <td style="padding: 10px; border-bottom: 1px solid #eee; text-align: right;">${item.price.toFixed(2)} €</td>
    </tr>
  `).join('');

  const html = `
    <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #ddd; border-radius: 8px; overflow: hidden;">
      <div style="background-color: #1a1a2e; color: white; padding: 20px; text-align: center;">
        <h1 style="margin: 0; font-size: 24px;">CONFIRMATION DE COMMANDE</h1>
        <p style="margin: 5px 0 0; opacity: 0.8;">Merci pour votre achat chez Shoe Store</p>
      </div>
      
      <div style="padding: 20px;">
        <p>Bonjour <strong>${user.displayName || 'Client'}</strong>,</p>
        <p>Votre commande a été validée avec succès. Voici le récapitulatif :</p>
        
        <div style="margin: 20px 0; border: 1px solid #eee; border-radius: 5px;">
          <table style="width: 100%; border-collapse: collapse;">
            <thead>
              <tr style="background-color: #f8f9fa;">
                <th style="padding: 10px; text-align: left; border-bottom: 2px solid #eee;">Produit</th>
                <th style="padding: 10px; text-align: center; border-bottom: 2px solid #eee;">Qté</th>
                <th style="padding: 10px; text-align: right; border-bottom: 2px solid #eee;">Prix</th>
              </tr>
            </thead>
            <tbody>
              ${itemsHtml}
            </tbody>
            <tfoot>
              <tr>
                <td colspan="2" style="padding: 15px 10px; text-align: right; font-weight: bold; font-size: 18px;">TOTAL</td>
                <td style="padding: 15px 10px; text-align: right; font-weight: bold; font-size: 18px; color: #e74c3c;">${order.totalAmount.toFixed(2)} €</td>
              </tr>
            </tfoot>
          </table>
        </div>

        <div style="display: flex; gap: 20px; margin-top: 20px;">
          <div style="flex: 1; background-color: #fcfcfc; padding: 15px; border-radius: 5px; border: 1px solid #f0f0f0;">
            <h4 style="margin: 0 0 10px; color: #555;">Détails de livraison</h4>
            <p style="margin: 0; font-size: 14px; line-height: 1.5;">
              ${order.shippingAddress.fullName}<br>
              ${order.shippingAddress.address}<br>
              ${order.shippingAddress.city}, ${order.shippingAddress.postalCode}<br>
              ${order.shippingAddress.country}
            </p>
          </div>
        </div>

        <div style="margin-top: 30px; text-align: center;">
          <p style="font-size: 14px; color: #888;">Numéro de commande : <strong>#${order._id}</strong></p>
          <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;">
          <p style="font-size: 12px; color: #aaa;">
            Vous recevrez un autre e-mail dès que votre colis sera expédié.
          </p>
        </div>
      </div>
    </div>
  `;

  return sendEmail(user.email, `Confirmation de commande Shoe Store - #${order._id}`, html);
};

/**
 * Send Password Reset Email
 * @param {string} email - User email
 * @param {string} code - 6-digit reset code
 */
const sendPasswordResetEmail = async (email, code) => {
  const html = `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #eee; padding: 20px; border-radius: 10px;">
      <h2 style="color: #2c3e50; text-align: center;">Réinitialisation de votre mot de passe</h2>
      <p>Bonjour,</p>
      <p>Vous avez demandé la réinitialisation de votre mot de passe. Voici votre code de vérification :</p>
      
      <div style="background-color: #f4f4f4; padding: 20px; text-align: center; border-radius: 5px; margin: 20px 0;">
        <span style="font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #3498db;">${code}</span>
      </div>

      <p>Ce code est valable pendant 10 minutes. Si vous n'êtes pas à l'origine de cette demande, vous pouvez ignorer cet e-mail.</p>
      
      <p style="text-align: center; margin-top: 30px; font-size: 12px; color: #7f8c8d;">
        Shoe Store Team
      </p>
    </div>
  `;

  return sendEmail(email, 'Code de réinitialisation du mot de passe', html);
};

module.exports = {
  sendEmail,
  sendOrderConfirmation,
  sendPasswordResetEmail
};
