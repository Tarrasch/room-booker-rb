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
    
    button.text("Hold on, making reservation");
    $.post("/reservation", {
      days: days,
      from: $("#timespan-start").val(),
      to: $("#timespan-end").val()
    }, function(data) {
      button.text(buttonData);
      $(".selectedDay").removeClass("selectedDay");
    });
  });
  
  $("#clear").click(function() {
    $(".selectedDay").removeClass("selectedDay");
  });
});

$(function() {
  var client = new Faye.Client("http://localhost:9999/faye");
  
  var subscription = client.subscribe("/reserve/" + $.cookie("uuid"), function(message) {
    console.debug("OKOKOKOKOKOKOKOKOKOKOKOKOKOKOKOK");
    console.debug("message", message);
  });
})