// allows for Shiny.onInputChange to send message immediately
// see https://github.com/rstudio/shiny/issues/1476
function SenderQueue() {
  this.readyToSend = true;
  this.queue = [];
  this.timer = null;
}
SenderQueue.prototype.send = function(name, value) {
  var self = this;
  function go() {
    self.timer = null;
    if (self.queue.length) {
      var msg = self.queue.shift();
      Shiny.onInputChange(msg.name, msg.value);
      self.timer = setTimeout(go, 0);
    } else {
      self.readyToSend = true;
    }
  }
  if (this.readyToSend) {
    this.readyToSend = false;
    Shiny.onInputChange(name, value);
    this.timer = setTimeout(go, 0);
  } else {
    this.queue.push({name: name, value: value});
    if (!this.timer) {
      this.timer = setTimeout(go, 0);
    }
  }
};

var queue = new SenderQueue();


