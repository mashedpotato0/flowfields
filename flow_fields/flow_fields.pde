float[][] grid; // 2D array to store angles
int resolution = 20; // Grid spacing
float stepLength = 5; // Step length for drawing curves
int cols, rows;

int numBalls = 1000; // Number of balls
ArrayList<Ball> balls = new ArrayList<Ball>();
ArrayList<ArrayList<PVector>> paths = new ArrayList<ArrayList<PVector>>();

void setup() {
  size(1500,900);
  //frameRate(30); // Set a lower frame rate
  cols = width / resolution;
  rows = height / resolution;
  grid = new float[cols][rows];
  initializeFlowField();

  // Initialize the positions of multiple balls and paths in a vertical line on the right edge
  float startX = width - 20; // Set the starting X position
  float startY = height; // Set the starting Y position

  for (int i = 0; i < numBalls; i++) {
    float spacing = height/numBalls; // Adjust the spacing between balls if needed
    balls.add(new Ball(random(0,width), random(0,height)));
    paths.add(new ArrayList<PVector>());
  }
}

void draw() {
  background(0); // Set background color to black
  //drawFlowField();
  updateBalls();
  drawPaths();
  //drawBalls();
}

void initializeFlowField() {
  for (int col = 0; col < cols; col++) {
    for (int row = 0; row < rows; row++) {
      float angle = map(noise(col * 0.1, row * 0.1), 0, 1, 0, TWO_PI);
      grid[col][row] = angle;
    }
  }
}

void drawFlowField() {
  stroke(255, 50); // Set the stroke color to white with transparency
  strokeWeight(1);
  for (int col = 0; col < cols; col++) {
    for (int row = 0; row < rows; row++) {
      float x = col * resolution;
      float y = row * resolution;
      float angle = grid[col][row];
      float x_step = cos(angle) * resolution * 0.5;
      float y_step = sin(angle) * resolution * 0.5;
      line(x, y, x + x_step, y + y_step);
    }
  }
}

void updateBalls() {
  for (int i = 0; i < balls.size(); i++) {
    Ball ball = balls.get(i);
    ball.update();

    if (ball.isOutOfBounds()) {
      // Start a new path for the ball
      paths.set(i, new ArrayList<PVector>());
    }

    // Add the current position to the path
    paths.get(i).add(new PVector(ball.x, ball.y));
  }
}

void drawPaths() {
  noFill();

  for (int i = 0; i < paths.size(); i++) {
    ArrayList<PVector> path = paths.get(i);
    if (path.size() > 1) {
      beginShape();
      for (int j = 0; j < path.size() - 1; j++) {
        PVector p1 = path.get(j);
        PVector p2 = path.get(j + 1);

        // Check the distance between consecutive points
        float distance = dist(p1.x, p1.y, p2.x, p2.y);

        if (distance < 200) {
          // Map the distance to determine the color
          float colorValue = map(distance, 0, 200, 255, 50);
          stroke(colorValue, 0, 0, 50); // Gradient path color
          strokeWeight(2);
          vertex(p1.x, p1.y);
        } else {
          // Start a new line
          endShape();
          beginShape();
        }
      }
      // Draw the last point
      vertex(path.get(path.size() - 1).x, path.get(path.size() - 1).y);
      endShape();
    }
  }
}

void drawBalls() {
  for (Ball ball : balls) {
    ball.display();
  }
}

class Ball {
  float x, y;
  float startX, startY;

  Ball(float startX, float startY) {
    this.startX = startX;
    this.startY = startY;
    this.x = startX;
    this.y = startY;
  }

  void update() {
    int colIndex = constrain(int(x / resolution), 0, cols - 1);
    int rowIndex = constrain(int(y / resolution), 0, rows - 1);

    float gridAngle = grid[colIndex][rowIndex];
    float x_step = stepLength * cos(gridAngle);
    float y_step = stepLength * sin(gridAngle);

    // Update ball position based on flow field
    x += x_step;
    y += y_step;

    // Wrap around the edges
    x = (x + width) % width;
    y = (y + height) % height;
  }

  boolean isOutOfBounds() {
    return x < 0 || x > width || y < 0 || y > height;
  }

  void display() {
    fill(255, 0, 0); // Red color for the ball
    noStroke();
    ellipse(x, y, 5, 5); // Draw the ball
  }
}
