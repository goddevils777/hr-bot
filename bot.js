const TelegramBot = require('node-telegram-bot-api');
const config = require('./config');
const survey = require('./handlers/survey');
const storage = require('./database/storage');

const bot = new TelegramBot(config.BOT_TOKEN, { polling: true });

console.log('✅ HR-бот запущен');

bot.setMyCommands([
  { command: 'start', description: 'Почати опитування' }
]);

bot.onText(/\/start/, (msg) => {
  const chatId = msg.chat.id;
  const userId = msg.from.id;
  const userInfo = {
    username: msg.from.username,
    phone: msg.contact ? msg.contact.phone_number : null
  };
  survey.handleStart(bot, chatId, userId, userInfo);
});

bot.onText(/\/stats/, (msg) => {
  const chatId = msg.chat.id;
  const userId = msg.from.id;

  if (userId.toString() !== config.ADMIN_CHAT_ID) {
    bot.sendMessage(chatId, '❌ У вас немає доступу до цієї команди.');
    return;
  }

  const data = storage.readData();
  const candidates = data.candidates;

  let notCompleted = [];
  let completed = [];

  for (let id in candidates) {
    const candidate = candidates[id];
    
    if (candidate.status === 'completed') {
      completed.push({
        username: candidate.username,
        phone: candidate.phone,
        id: id,
        about: candidate.about
      });
    } else {
      notCompleted.push({
        username: candidate.username,
        phone: candidate.phone,
        id: id
      });
    }
  }

  let report = '📊 Статистика кандидатів\n\n';

  report += `✅ Завершили анкету: ${completed.length}\n`;
  report += `⏳ Почали, але не завершили: ${notCompleted.length}\n\n`;

  if (notCompleted.length > 0) {
    report += '⏳ Не завершили:\n';
    notCompleted.forEach((c, index) => {
      report += `${index + 1}. ${c.username ? '@' + c.username : 'немає ніка'}`;
      if (c.phone) report += ` | 📱 ${c.phone}`;
      report += ` | ID: ${c.id}\n`;
    });
  }

  bot.sendMessage(chatId, report);
});

bot.on('message', (msg) => {
  console.log('📨 Получено сообщение:', msg.text || 'контакт');
  console.log('👤 От пользователя:', msg.from.id);
  
  if (msg.contact) {
    survey.handleMessage(bot, msg);
    return;
  }
  
  if (msg.text && !msg.text.startsWith('/')) {
    survey.handleMessage(bot, msg);
  }
});

bot.on('polling_error', (error) => {
  console.error('Ошибка polling:', error.message);
});