// Based on code by Sau Sheong
// https://towardsdatascience.com/simulating-epidemics-using-go-and-python-101557991b20

final int gWidth = 60;
final int filename = 1;

final float rate = 0.15;
final int incubation = 3;
final int duration = 4;
final float density = .75;
final float fatality = .1;
final float immunity = .005;

final int medIntroduced = 90;  // day when medicine is introduced
final float medEffectiveness = .8;  // effectivness of medicine
final int qIntroduced = 60;  // day when quarentine is introduced 
final float qEffectiveness = .6; // quarentine effectiveness

final int CELLSIZE = 15;

Cell[] cells = new Cell[(gWidth-1)*(gWidth-1)];
int interactions = 0;
float coverage = 1;
int numTicks = 0;
int infected = 0;
int recovered = 0;
int dead = 0;

boolean endSim = false;

class Cell {
   int X, Y, R;
   int Incubation;
   boolean Infected;
   int Duration;
   float Immunity;
   boolean Medicated;
   boolean Quarantined;
   color Color;
   
   Cell(int x, int y, int clr) {
     X = x;
     Y = y;
     R = CELLSIZE;
     Color = color(clr);
   }
   
   int getRGB() {
     return int(this.Color);
   }
   
   void setRGB(int i) {
     this.Color = color(i);
   }
   
   void infected() {
     this.setRGB(0xFFCC99);
     this.Infected = true;
     this.Incubation = incubation;
     this.Duration = duration;
     infected++;
   }
   
   void recover() {
     this.setRGB(0x00FF00);
     this.Infected = false;
     this.Incubation = 0;
     this.Duration = 0;
     this.Immunity = immunity;
     recovered++;
     infected--;
   }
   
   void die() {
     this.setRGB(0);
     this.Infected = false;
     this.Duration = 0;
     dead++;
     infected--;
   }
   
   void quarantine() {
     this.setRGB(0x99CCFF);
     this.Quarantined = true;
   }
   
   void medicate() {
     if (random(1) < medEffectiveness) {
       this.recover();
     } else {
       this.Medicated = true; 
     }
   }
   
   void process() {
     if (this.Infected) {
       if (this.Incubation > 0) {
         this.Incubation -= 1;
       } else {
         this.setRGB(0xFF0000);
         if (this.Duration > 0) {
           this.Duration -= 1;
         } else {
           if (random(1) > fatality) {
             this.recover();
           } else {
             this.die();
           }
         }
       }
     }
   }
   
  void draw() {
   pushStyle();
   fill(red(this.Color), blue(this.Color), green(this.Color));
   circle(this.X, this.Y, this.R);
   popStyle();
  }
}

Cell[] createPopulation() {
  int n = 0;
  for (int i = 1; i < gWidth; i++) {
    for (int j = 1; j < gWidth; j++) {
      float p = random(1);
      if (p < density) {
        cells[n] = new Cell(i*CELLSIZE, j*CELLSIZE, color(0, 0, 255)); 
      } else {
        cells[n] = new Cell(i*CELLSIZE, j*CELLSIZE, 0x000000); 
      }
      n++;
    }
  }
  return cells;
}

IntList findNeighboursIndex(int n) {
  IntList nb = new IntList();
  if (topLeft(n)) {
    nb.append(c5(n));
    nb.append(c7(n));
    nb.append(c8(n));
  } else if (topRight(n)) {
    nb.append(c4(n));
    nb.append(c6(n));
    nb.append(c7(n));
  } else if (bottomLeft(n)) {
    nb.append(c2(n));
    nb.append(c3(n));
    nb.append(c5(n));
  } else if (bottomRight(n)) {
    nb.append(c1(n));
    nb.append(c2(n));
    nb.append(c4(n));
  } else if (top(n)) {
    nb.append(c4(n));
    nb.append(c5(n));
    nb.append(c6(n));
    nb.append(c7(n));
    nb.append(c8(n));
  } else if (left(n)) {
    nb.append(c2(n));
    nb.append(c3(n));
    nb.append(c5(n));
    nb.append(c7(n));
    nb.append(c8(n));
  } else if (right(n)) {
    nb.append(c1(n));
    nb.append(c2(n));
    nb.append(c4(n));
    nb.append(c8(n));
    nb.append(c7(n));
  } else if (bottom(n)) {
    nb.append(c1(n));
    nb.append(c2(n));
    nb.append(c3(n));
    nb.append(c4(n));
    nb.append(c5(n));
  } else {
    nb.append(c1(n));
    nb.append(c2(n));
    nb.append(c3(n));
    nb.append(c4(n));
    nb.append(c5(n));
    nb.append(c6(n));
    nb.append(c7(n));
    nb.append(c8(n));
  }
  return nb;
}

boolean topLeft(int n) { return n == 0; }
boolean topRight(int n) { return n == gWidth-1; }
boolean bottomLeft(int n) { return n == gWidth*(gWidth-1); }
boolean bottomRight(int n) { return n == (gWidth*gWidth)-1; }

boolean top(int n) { return n < gWidth; }
boolean left(int n) { return n % (gWidth) == 0; }
boolean right(int n) { return n % (gWidth) == gWidth - 1; }
boolean bottom(int n) { return n >= gWidth*(gWidth-1); }

int c1(int n) { return n - gWidth - 1; }
int c2(int n) { return n - gWidth; }
int c3(int n) { return n - gWidth + 1; }
int c4(int n) { return n - 1; }
int c5(int n) { return n + 1; }
int c6(int n) { return n + gWidth - 1; }
int c7(int n) { return n + gWidth; }
int c8(int n) { return n + gWidth + 1; }

void infectOneCell(Cell[] cells) {
  int xr = int(random((gWidth-1)*(gWidth-1)));
  
  cells[xr].infected();
}

void settings() {
  final int w = gWidth * CELLSIZE;
  size(w ,w);
}

void setup() {
  colorMode(RGB, 255);
  frameRate(5);
  background(255);
  noStroke();

  cells = createPopulation();
  infectOneCell(cells);
}

void draw() {
  int t = frameCount;
  for (int n=0; n < (gWidth-1)*(gWidth-1) - 1; n++) {
    cells[n].draw();
    if (cells[n].getRGB() == 0 || !cells[n].Infected) {
      continue;
    }
    
    cells[n].process();
    
    if (!cells[n].Infected || cells[n].Incubation > 0) {
      continue; 
    }
    
    if (!cells[n].Medicated && (t > medIntroduced)) {
      cells[n].medicate(); 
    }
    
    if (!cells[n].Infected) {
      continue; 
    }
    
    if (!cells[n].Quarantined && (t > qIntroduced) && (random(1) < qEffectiveness)) {
      cells[n].quarantine();
    }
    
    if (!cells[n].Quarantined) {
      IntList neighbors = findNeighboursIndex(n);
      
      for (int neighbor: neighbors) {
         neighbor = constrain(neighbor, 1, cells.length-1);
         if (cells[neighbor].getRGB() == 0 || cells[neighbor].Infected) {
           continue; 
         }
         
         if (random(1) > cells[neighbor].Immunity) {
           if (random(1) < rate) {
             cells[neighbor].infected();
           }
         }
      }
    }
  }
  println("infected: ", infected);
  println("dead: ", dead);
  println("recovered", recovered);
  println("---");
}
