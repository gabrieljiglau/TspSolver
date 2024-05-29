package com.classroom;

import com.classroom.services.TSPSolverGUI;

import javax.swing.*;

public class Main {

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> new TSPSolverGUI().setVisible(true));
    }
}
