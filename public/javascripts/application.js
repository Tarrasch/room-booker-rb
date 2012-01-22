$(function () {
  var days
  $('#calOne').jCal({
    day: new Date(),
    days: 4,
    showMonths: 2,
    monthSelect: true
  });
});

$(function () {
  var button = $("#make-reservation");
  var buttonData = button.text();
  
  $("#calOneDays").change(function () {
    $('#calOne').data('days', $('#calOneDays').val());
  });
  
  button.click(function() {
    var days = [];
    $(".selectedDay").each(function(i, item) {
      var match = item.id.match(/^c2d_(\d+)_(\d+)_(\d+)/);
      days.push(new Date(match[3] + "-" + match[1] + "-" + match[2]).getTime() / 1000);
    });
    
    if(days.length === 0){
      return;
    }
    
    button.text("Hold on");
    $.post("/reservation", {
      days: days,
      from: $("#timespan-start").val(),
      to: $("#timespan-end").val(),
      floor: $("#floor").val()
    }, function(data) {
      button.text(buttonData);
    });
  });
  
  $("#clear").click(function() {
    window.location.reload();
  });
});

$(function() {
  var client, subscription, day, data;
  client = new Faye.Client("http://localhost:9999/faye");
  subscription = client.subscribe("/reserve/" + $.cookie("uuid"), function(message) {
    message = JSON.parse(message)
    if(message.type == "message" && message.notification){
      day = new Date(parseInt(message.day, 10) * 1000);
      data = $('[id*=d_' + (day.getMonth() + 1) + '_' + day.getDate() + '_' + day.getFullYear() + ']');
      if(message.notification == "valid"){
        data.css({"background-color": "green"});
      } else if(message.notification == "no_room"){
        data.css({"background-color": "yellow"});
      } else {
        data.css({"background-color": "red"});
      }
      
      data.removeClass("selectedDay");
    }
  });
})