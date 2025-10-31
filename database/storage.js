const fs = require('fs');
const path = require('path');

const DATA_FILE = path.join(__dirname, 'candidates.json');

class Storage {
  constructor() {
    this.ensureDataFile();
  }

  ensureDataFile() {
    if (!fs.existsSync(DATA_FILE)) {
      fs.writeFileSync(DATA_FILE, JSON.stringify({ candidates: {} }, null, 2));
    }
  }

  readData() {
    const data = fs.readFileSync(DATA_FILE, 'utf8');
    return JSON.parse(data);
  }

  writeData(data) {
    fs.writeFileSync(DATA_FILE, JSON.stringify(data, null, 2));
  }

  getCandidate(userId) {
    const data = this.readData();
    return data.candidates[userId] || null;
  }

  saveCandidate(userId, candidateData) {
    const data = this.readData();
    data.candidates[userId] = {
      ...data.candidates[userId],
      ...candidateData,
      updatedAt: new Date().toISOString()
    };
    this.writeData(data);
  }

  updateCandidateField(userId, field, value) {
    const data = this.readData();
    if (!data.candidates[userId]) {
      data.candidates[userId] = {};
    }
    data.candidates[userId][field] = value;
    data.candidates[userId].updatedAt = new Date().toISOString();
    this.writeData(data);
  }
}

module.exports = new Storage();
