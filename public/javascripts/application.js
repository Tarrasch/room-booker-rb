function pad(number, length) {
  var str = '' + number;
  while (str.length < length) {
    str = '0' + str;
  }
  return str;
}

function addReservation(day, room){
  var curr_date, curr_month, curr_year, $list;
  $list = $("ul#reservations");
  curr_date = day.getDate();
  curr_month = day.getMonth() + 1;
  curr_year = day.getFullYear();
  $list.append("<li>" + curr_year + "-" + pad(curr_month, 2) + "-" + pad(curr_date, 2) + " - " + room + "</li>");
}

$(function () {
  $("#calOne").jCal({
    day: new Date(),
    days: 4,
    showMonths: 2,
    monthSelect: true
  });
  
      
  var reservations = JSON.parse(localStorage.getItem("reservations") || "[]");
  $(reservations).each(function(index, reservation) {
    var day, data;
    day = new Date(reservation.day);
    addReservation(day, reservation.room);
    data = $("[id*=d_" + (day.getMonth() + 1) + "_" + day.getDate() + "_" + day.getFullYear() + "]");
    data.css({"background-color": "green"});
  });
});

var button, buttonData;

$(function () { 
  button = $("#make-reservation");
  buttonData = button.text();
   
  $("#calOneDays").change(function () {
    $("#calOne").data("days", $("#calOneDays").val());
  });
  
  button.click(function() {
    var days = [];
    $(".selectedDay").each(function(i, item) {
      var match = item.id.match(/^c2d_(\d+)_(\d+)_(\d+)/);
      days.push(new Date(match[3] + "-" + match[1] + "-" + match[2]).getTime() / 1000);
    });
    
    if(days.length === 0){
      $.gritter.add({
        title: "Error",
        text: "No days selected"
      });
      return;
    }
    
    button.text("Hold on");
    $.post("/reservation", {
      days: days,
      from: $("#timespan-start").val(),
      to: $("#timespan-end").val(),
      floor: $("#floor").val(),
      username: localStorage.getItem("username"),
      password: localStorage.getItem("password")
    });
  });
  
  $("#clear").click(function() {
    var con = confirm("Clear screen and reservations?");
    if(con){
      localStorage.setItem("reservations", "[]");
      window.location.reload();
    }
  });
});

$(function() {
  $("#username, #password").keyup(function() {
    localStorage.setItem($(this).attr("id"), $(this).val());
  });
  
  $("#username").val(localStorage.getItem("username"));
  $("#password").val(localStorage.getItem("password"));
});

$(function() {
  $([".red", ".green", ".yellow"]).each(function(index, klass) {
    $(klass).addGlow();
    $(klass).click(function(e) {
      $.gritter.add({
        title: "Color explanation",
        text: $(e.target).attr("title")
      });
    })
  });
})

$(function() {
  var client, subscription, day, data;
  client = new Faye.Client("http://" + document.domain + ":9999/faye");
  subscription = client.subscribe("/reserve/" + $.cookie("uuid"), function(message) {
    message = JSON.parse(message);
        
    if(message.type == "end"){
      button.text(buttonData);
    }
    
    if(message.type == "message" && message.notification){
      if(message.notification == "invalid_credentials"){
        $.gritter.add({
          title: "Error",
          text: "Invalid user credentials"
        });        
        return;
      }
      
      day = new Date(parseInt(message.day, 10) * 1000);
      data = $("[id*=d_" + (day.getMonth() + 1) + "_" + day.getDate() + "_" + day.getFullYear() + "]");
      if(message.notification == "valid"){
        addReservation(day, message.room);
        
        var reservations = JSON.parse(localStorage.getItem("reservations") || "[]");
        
        reservations.push({
          day: day.getTime(),
          room: message.room
        });
        
        localStorage.setItem("reservations", JSON.stringify(reservations));
        $(".green").trigger("mouseenter");
        data.css({"background-color": "green"});
      } else if(message.notification == "no_room"){
        $(".yellow").trigger("mouseenter");
        data.css({"background-color": "yellow"});
      } else {
        $.gritter.add({
          title: "Error",
          text: message.notification
        });
        data.css({"background-color": "red"});
        $(".red").trigger("mouseenter");
      }
            
      data.removeClass("selectedDay");
    }
  });
});