package app;

import java.io.File;
import java.io.RandomAccessFile;
import java.util.Arrays;

public class DBUsers {
    private static RandomAccessFile db;
    public static void open() {
        try {
            db = new RandomAccessFile(new File("users.db"), "rw");
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
    public static void write(DBUser user) {
        byte[] id;
        byte[] username;
        byte[] pin;
        byte[] irons;
        {
            id = Arrays.copyOf(user.id.getBytes(), 16);
            username = Arrays.copyOf(user.username.getBytes(), 32);
            pin = Arrays.copyOf(user.pin.getBytes(), 4);
            irons = Arrays.copyOf(String.valueOf(user.irons).getBytes(), 8);
        }
        try {
            db.seek(db.length());
            db.setLength(db.length() + (long) 16 + 32 + 4 + 8);
            db.write(id);
            db.write(username);
            db.write(pin);
            db.write(irons);
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
    public static void change(long position, DBUser user) {
        try {
            db.seek(position);
            db.write(Arrays.copyOf(user.id.getBytes(), 16));
            db.write(Arrays.copyOf(user.username.getBytes(), 32));
            db.write(Arrays.copyOf(user.pin.getBytes(), 4));
            db.write(Arrays.copyOf(String.valueOf(user.irons).getBytes(), 8));
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
    public static DBUser findById(String id) {
        DBUser user = new DBUser();
        user.id = "";
        byte[] unknown = Arrays.copyOf(id.getBytes(), 16);
        try {
            for (long i = 0; i < db.length() / ((long) 16 + 32 + 4 + 8); i++) {
                db.seek(i * ((long) 16 + 32 + 4 + 8));
                byte[] possible = new byte[16];
                db.read(possible);
                if (Arrays.equals(possible, unknown)) {
                    user.positon = i * ((long) 16 + 32 + 4 + 8);
                    user.id = new String(possible, 0, 16).replaceAll("\0", "");
                    {
                        byte[] username_byte = new byte[32];
                        db.read(username_byte);
                        user.username = new String(username_byte, 0, 32).replaceAll("\0", "");
                        byte[] pin_byte = new byte[4];
                        db.read(pin_byte);
                        user.pin = new String(pin_byte, 0, 4).replaceAll("\0", "");
                        byte[] irons_byte = new byte[8];
                        db.read(irons_byte);
                        user.irons = Integer.parseInt(new String(irons_byte, 0, 8).replaceAll("\0", ""));
                    }
                    break;
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return user;
    }
}
