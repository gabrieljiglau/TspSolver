package com.classroom.repository;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseManager {
    public static double getOriginalDistance(String url, String username, String password, int numberOfNodes) throws SQLException {
        try (Connection connection = DriverManager.getConnection(url, username, password);
             CallableStatement cstmt = connection.prepareCall("{ ? = call get_original_distance(?) }")) {

            cstmt.registerOutParameter(1, java.sql.Types.NUMERIC);
            cstmt.setInt(2, numberOfNodes);
            cstmt.execute();
            return cstmt.getDouble(1);
        }
    }

    public static double getImprovedDistance(String url, String username, String password, int numberOfNodes) throws SQLException {
        try (Connection connection = DriverManager.getConnection(url, username, password);
             CallableStatement cstmt = connection.prepareCall("{ ? = call get_improved_distance(?) }")) {

            cstmt.registerOutParameter(1, java.sql.Types.NUMERIC);
            cstmt.setInt(2, numberOfNodes);
            cstmt.execute();
            return cstmt.getDouble(1);
        }
    }
}
