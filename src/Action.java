package app;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;

import java.io.IOException;
import java.util.Random;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Action implements HttpHandler {
    @Override
    public void handle(HttpExchange exchange) throws IOException {
        if (exchange.getRequestURI().getPath().equals("/create")) {
            String id = "";
            {
                StringBuilder id_builder = new StringBuilder();
                String chars = "0123456789";
                Random random = new Random();
                for (int i = 0; i < 16; i++) {
                    id_builder.append(chars.charAt(random.nextInt(9)));
                }
                id = id_builder.toString();
            }
            String username = "";
            String pin = "";
            {
                byte[] response_byte = new byte[512];
                int response_length = exchange.getRequestBody().read(response_byte);
                String response = new String(response_byte, 0, response_length);
                Pattern pattern = Pattern.compile("username=(.*)&pin=(.*)");
                Matcher matcher = pattern.matcher(response);
                if (matcher.find()) {
                    username = matcher.group(1);
                    pin = matcher.group(2);
                }
            }
            DBUser user = new DBUser();
            {
                user.id = id;
                user.username = username;
                user.pin = pin;
                user.irons = 0;
            }
            DBUsers.write(user);
            String response = user.id;
            exchange.sendResponseHeaders(200, response.getBytes().length);
            exchange.getResponseBody().write(response.getBytes());
            exchange.close();
        }
        else if (exchange.getRequestURI().getPath().equals("/getUsername")) {
            String id = "";
            {
                byte[] id_byte = new byte[16];
                int id_length = exchange.getRequestBody().read(id_byte);
                id = new String(id_byte, 0, id_length);
            }
            DBUser user = DBUsers.findById(id);
            if (user.id.equals("")) {
                exchange.sendResponseHeaders(200, 0);
                exchange.close();
                return;
            }
            String response = user.username;
            exchange.sendResponseHeaders(200, response.getBytes().length);
            exchange.getResponseBody().write(response.getBytes());
        }
        else if (exchange.getRequestURI().getPath().equals("/getIrons")) {
            String id = "";
            {
                byte[] id_byte = new byte[16];
                int id_length = exchange.getRequestBody().read(id_byte);
                id = new String(id_byte, 0, id_length);
            }
            DBUser user = DBUsers.findById(id);
            if (user.id.equals("")) {
                exchange.sendResponseHeaders(200, 0);
                exchange.close();
                return;
            }
            String response = String.valueOf(user.irons);
            exchange.sendResponseHeaders(200, response.getBytes().length);
            exchange.getResponseBody().write(response.getBytes());
        }
        else if (exchange.getRequestURI().getPath().equals("/deposit")) {
            String id = "";
            int irons = 0;
            {
                byte[] response_byte = new byte[512];
                int response_length = exchange.getRequestBody().read(response_byte);
                String response = new String(response_byte, 0, response_length);
                Pattern pattern = Pattern.compile("id=(.*)&amount=(.*)");
                Matcher matcher = pattern.matcher(response);
                if (matcher.find()) {
                    id = matcher.group(1);
                    irons = Integer.parseInt(matcher.group(2));
                }
                else {
                    exchange.sendResponseHeaders(500, 0);
                    exchange.close();
                    return;
                }
            }
            DBUser user = DBUsers.findById(id);
            if (user.id.equals("")) {
                exchange.sendResponseHeaders(200, 0);
                exchange.close();
                return;
            }
            user.irons += irons;
            DBUsers.change(user.positon, user);
            exchange.sendResponseHeaders(200, 0);
            exchange.close();
        }
        else if (exchange.getRequestURI().getPath().equals("/withdraw")) {
            String id = "";
            String pin = "";
            int irons = 0;
            {
                byte[] response_byte = new byte[512];
                int response_length = exchange.getRequestBody().read(response_byte);
                String response = new String(response_byte, 0, response_length);
                Pattern pattern = Pattern.compile("id=(.*)&pin=(.*)&amount=(.*)");
                Matcher matcher = pattern.matcher(response);
                if (matcher.find()) {
                    id = matcher.group(1);
                    pin = matcher.group(2);
                    irons = Integer.parseInt(matcher.group(3));
                }
                else {
                    exchange.sendResponseHeaders(500, 0);
                    exchange.close();
                    return;
                }
            }
            DBUser user = DBUsers.findById(id);
            if (user.id.equals("")) {
                exchange.sendResponseHeaders(200, 0);
                exchange.close();
                return;
            }
            if (!user.pin.equals(pin)) {
                String response = "wrongpin";
                exchange.sendResponseHeaders(200, response.getBytes().length);
                exchange.getResponseBody().write(response.getBytes());
                exchange.close();
                return;
            }
            irons = Math.abs(irons);
            if (user.irons < irons) {
                String response = "dontenough";
                exchange.sendResponseHeaders(200, response.getBytes().length);
                exchange.getResponseBody().write(response.getBytes());
                exchange.close();
                return;
            }
            user.irons -= irons;
            DBUsers.change(user.positon, user);
            {
                String response = "ok";
                exchange.sendResponseHeaders(200, response.getBytes().length);
                exchange.getResponseBody().write(response.getBytes());
            }
            exchange.close();
        }
    }
}
