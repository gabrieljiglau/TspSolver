package com.classroom.resources;

import javax.imageio.ImageIO;
import javax.swing.*;
import java.awt.*;
import java.io.File;
import java.io.IOException;

public class BackgroundImage extends JPanel {
    private Image backgroundImage;

    public BackgroundImage() {
        try {

            backgroundImage = ImageIO.read(new File
                    ("C:\\Users\\gabri\\IdeaProjects\\PLSQL\\src\\main\\java\\com\\classroom\\resources\\Background.JPG"));
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void paintComponent(Graphics g) {
        super.paintComponent(g);
        if (backgroundImage != null) {
            g.drawImage(backgroundImage, 0, 0, getWidth(), getHeight(), this);
        }
    }
}
