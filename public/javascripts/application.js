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
    var days = $(".selectedDay").map(function(i, item) {
      var match = item.id.match(/^c2d_(\d+)_(\d+)_(\d+)/);
      return new Date(match[3] + "-" + match[1] + "-" + match[2]);
    });
    
    button.text("Hold on, making reservation");
    
    setTimeout(function() {
      button.text(buttonData);
      $(".selectedDay").removeClass("selectedDay");
    }, 1000);
  });
  
  $("#clear").click(function() {
    $(".selectedDay").removeClass("selectedDay");
  })
});