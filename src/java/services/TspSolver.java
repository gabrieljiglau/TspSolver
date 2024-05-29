package com.classroom.services;

import com.classroom.repository.DatabaseManager;

import java.sql.SQLException;

public class TspSolver {
    public static double computeOriginalDistance(String url, String username, String password, int numberOfNodes) {
        try {
            return DatabaseManager.getOriginalDistance(url, username, password, numberOfNodes);
        } catch (SQLException e) {
            e.printStackTrace();
            return -1; // Return an error value
        }
    }

    public static double computeImprovedDistance(String url, String username, String password, int numberOfNodes) {
        try {
            return DatabaseManager.getImprovedDistance(url, username, password, numberOfNodes);
        } catch (SQLException e) {
            e.printStackTrace();
            return -1; // Return an error value
        }
    }
}
