package app;

import com.sun.net.httpserver.HttpServer;

import java.net.InetAddress;
import java.net.InetSocketAddress;

public class Main {
    public static void main(String[] args) {
        DBUsers.open();
        try {
            HttpServer server = HttpServer.create(new InetSocketAddress(8000), 0);
            server.createContext("/", new Action());
            server.start();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
}
