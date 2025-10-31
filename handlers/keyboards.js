module.exports = {
  experience: {
    reply_markup: {
      keyboard: [
        [{ text: 'Є досвід' }],
        [{ text: 'Немає досвіду' }]
      ],
      resize_keyboard: true,
      one_time_keyboard: true
    }
  },

  sociability: {
    reply_markup: {
      keyboard: [
        [{ text: '0' }, { text: '1' }, { text: '2' }],
        [{ text: '3' }, { text: '4' }, { text: '5' }]
      ],
      resize_keyboard: true,
      one_time_keyboard: true
    }
  },

  requestContact: {
    reply_markup: {
      keyboard: [
        [{ text: '📱 Поділитися номером телефону', request_contact: true }]
      ],
      resize_keyboard: true,
      one_time_keyboard: true
    }
  },

  remove: {
    reply_markup: {
      remove_keyboard: true
    }
  }
};