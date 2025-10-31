const storage = require('../database/storage');
const messages = require('./messages');
const keyboards = require('./keyboards');

const STEPS = {
  START: 'start',
  REQUEST_CONTACT: 'request_contact',
  ABOUT: 'about',
  SOCIABILITY: 'sociability',
  CITY: 'city',
  DONE: 'done'
};

class Survey {
  handleStart(bot, chatId, userId, userInfo) {
    storage.saveCandidate(userId, { 
      step: STEPS.START, 
      chatId: chatId,
      username: userInfo.username || null,
      phone: userInfo.phone || null,
      startedAt: new Date().toISOString(),
      status: 'started'
    });

    console.log('🔄 Новый кандидат создан');

    if (!userInfo.username && !userInfo.phone) {
      storage.updateCandidateField(userId, 'step', STEPS.REQUEST_CONTACT);
      bot.sendMessage(chatId, 'Для продовження, будь ласка, поділіться вашим номером телефону.', keyboards.requestContact);
    } else {
      storage.updateCandidateField(userId, 'step', STEPS.ABOUT);
      bot.sendMessage(chatId, messages.welcome, keyboards.experience);
    }
  }

  handleContact(bot, msg) {
    const chatId = msg.chat.id;
    const userId = msg.from.id;
    const phone = msg.contact.phone_number;

    storage.updateCandidateField(userId, 'phone', phone);
    storage.updateCandidateField(userId, 'step', STEPS.ABOUT);
    bot.sendMessage(chatId, messages.welcome, keyboards.experience);
  }

  handleMessage(bot, msg) {
    const chatId = msg.chat.id;
    const userId = msg.from.id;
    const text = msg.text;

    console.log('🔍 handleMessage вызван');
    console.log('📝 Текст:', text);
    console.log('👤 UserID:', userId);

    if (msg.contact) {
      console.log('📞 Обнаружен контакт');
      this.handleContact(bot, msg);
      return;
    }

    const candidate = storage.getCandidate(userId);
    console.log('💾 Кандидат из БД:', candidate ? 'найден' : 'не найден');
    
    if (!candidate) {
      console.log('⚠️ Кандидат не найден, создаём нового');
      const userInfo = {
        username: msg.from.username,
        phone: msg.contact ? msg.contact.phone_number : null
      };
      this.handleStart(bot, chatId, userId, userInfo);
      return;
    }

    const step = candidate.step;
    console.log('📍 Текущий шаг:', step);

    switch (step) {
      case STEPS.REQUEST_CONTACT:
        bot.sendMessage(chatId, 'Будь ласка, використовуйте кнопку нижче для відправки номера.', keyboards.requestContact);
        break;
      case STEPS.ABOUT:
        this.handleAboutResponse(bot, chatId, userId, text);
        break;
      case STEPS.SOCIABILITY:
        this.handleSociabilityResponse(bot, chatId, userId, text);
        break;
      case STEPS.CITY:
        this.handleCityResponse(bot, chatId, userId, text);
        break;
    }
  }

  handleAboutResponse(bot, chatId, userId, text) {
    console.log('✅ Обрабатываем информацию о себе');
    
    if (text === 'Є досвід' || text === 'Немає досвіду') {
      storage.updateCandidateField(userId, 'experience', text);
      storage.updateCandidateField(userId, 'about', text);
    } else {
      storage.updateCandidateField(userId, 'about', text);
    }
    
    storage.updateCandidateField(userId, 'step', STEPS.SOCIABILITY);
    bot.sendMessage(chatId, messages.sociability, keyboards.sociability);
  }

  handleSociabilityResponse(bot, chatId, userId, text) {
    console.log('✅ Обрабатываем общительность');
    storage.updateCandidateField(userId, 'sociability', text);
    storage.updateCandidateField(userId, 'step', STEPS.CITY);
    bot.sendMessage(chatId, messages.city, keyboards.remove);
  }

  handleCityResponse(bot, chatId, userId, text) {
    console.log('✅ Обрабатываем город');
    storage.updateCandidateField(userId, 'city', text);
    storage.updateCandidateField(userId, 'step', STEPS.DONE);
    storage.updateCandidateField(userId, 'status', 'completed');
    storage.updateCandidateField(userId, 'completedAt', new Date().toISOString());
    
    bot.sendMessage(chatId, messages.completed, keyboards.remove);
    this.notifyAdmin(bot, userId);
  }

  notifyAdmin(bot, userId) {
    const config = require('../config');
    const candidate = storage.getCandidate(userId);
    
    const report = `
🆕 Нова анкета кандидата!

📝 Про себе та досвід: ${candidate.about}
💬 Рівень спілкування: ${candidate.sociability}/5
🏙 Місто: ${candidate.city}

Telegram: ${candidate.username ? '@' + candidate.username : 'не вказано'}
${candidate.phone ? '📱 Телефон: ' + candidate.phone : ''}
ID: ${userId}
    `;
    
    bot.sendMessage(config.ADMIN_CHAT_ID, report);
  }
}

module.exports = new Survey();