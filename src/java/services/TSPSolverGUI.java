package com.classroom.services;

import com.classroom.resources.BackgroundImage;

import javax.swing.*;
import javax.swing.border.CompoundBorder;
import javax.swing.border.EmptyBorder;
import java.awt.*;


public class TSPSolverGUI extends JFrame {

    private final JSpinner nodesSpinner;
    private final JLabel resultLabel;

    public TSPSolverGUI() {
        setTitle("Compute TSP");
        setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        setResizable(false);

        // Set the background image directly to the JFrame
        setContentPane(new BackgroundImage());

        JPanel mainPanel = new JPanel();
        mainPanel.setLayout(new BorderLayout());
        mainPanel.setBorder(new EmptyBorder(20, 20, 20, 20));

        JPanel inputPanel = new JPanel(new FlowLayout(FlowLayout.CENTER));
        JLabel titleLabel = new JLabel("Number of nodes : ");
        titleLabel.setFont(new Font("Arial", Font.BOLD, 16));
        inputPanel.add(titleLabel);
        nodesSpinner = new JSpinner(new SpinnerNumberModel(10, 2, 100, 1));
        nodesSpinner.setFont(new Font("Arial", Font.PLAIN, 16));
        inputPanel.add(nodesSpinner);
        mainPanel.add(inputPanel, BorderLayout.NORTH);

        JPanel resultPanel = new JPanel(new FlowLayout(FlowLayout.CENTER));
        resultLabel = new JLabel();
        resultLabel.setFont(new Font("Arial", Font.PLAIN, 16));
        resultPanel.add(resultLabel);
        mainPanel.add(resultPanel, BorderLayout.CENTER);

        JPanel buttonPanel = new JPanel(new FlowLayout(FlowLayout.CENTER));
        JButton computeNNButton = new JButton("Compute NN");
        computeNNButton.setFont(new Font("Arial", Font.BOLD, 16));
        computeNNButton.setFocusPainted(false);
        computeNNButton.setBorder(new CompoundBorder(
                new RoundedBorder(10, Color.BLACK),
                new EmptyBorder(5, 15, 5, 15))); // Added margin
        computeNNButton.addActionListener(e -> computeTSP());
        buttonPanel.add(computeNNButton);

        JButton compute2OptButton = new JButton("Compute 2-Opt");
        compute2OptButton.setFont(new Font("Arial", Font.BOLD, 16));
        compute2OptButton.setFocusPainted(false);
        compute2OptButton.setBorder(new CompoundBorder(
                new RoundedBorder(10, Color.BLACK),
                new EmptyBorder(5, 15, 5, 15))); // Added margin
        compute2OptButton.addActionListener(e -> compute2OptTSP());
        buttonPanel.add(compute2OptButton);

        mainPanel.add(buttonPanel, BorderLayout.SOUTH);

        add(mainPanel); // Add main panel to the content pane
        // Set preferred size of the JFrame
        setPreferredSize(new Dimension(558, 507)); // Adjust dimensions as needed
        pack(); // Pack components
        setLocationRelativeTo(null); // Center the window
    }

    private void computeTSP() {
        String url = "jdbc:oracle:thin:@127.0.0.1:1521:XE";
        String username = "sys as sysdba";
        String password = "sys123";

        int numberOfNodes = (int) nodesSpinner.getValue(); // Get the value from the spinner
        double originalDistance = TspSolver.computeOriginalDistance(url, username, password, numberOfNodes);

        resultLabel.setText("Original Total Distance: " + originalDistance);
    }

    private void compute2OptTSP() {
        String url = "jdbc:oracle:thin:@127.0.0.1:1521:XE";
        String username = "sys as sysdba";
        String password = "sys123";

        int numberOfNodes = (int) nodesSpinner.getValue(); // Get the value from the spinner
        double improvedDistance = TspSolver.computeImprovedDistance(url, username, password, numberOfNodes);

        resultLabel.setText("Improved Total Distance: " + improvedDistance);
    }
}
