+++
date= 2022-02-10T16:42:53+01:00
draft= false
tags= ["Physics", "Time", "Initial-Conditions", "Cellular Automata", "Lee-Smolin", "Causal-Sets", "John-Conway", "Game-of-Life"]
title = 'Conway Game of Life'
+++

{{< details summary="Warning!" >}}
This article is one among many salvaged from my previous blog! It is not on par with my demands of quality but I didn't feel like abandoning it.

I wrote a larger article titled as "[An Analogy to Dive Deep Into the Nature of Time](https://website-5m1.pages.dev/posts/an-analogy-to-dive-deep-into-the-nature-of-time/)" but didn't feel comfortable posting the whole thing here, so I just picked the stuff I felt that is worth posting.
{{< /details >}}

Time is a concept many philosophers and physicists pondered upon for centuries. It still remains mysterious besides the metaphysical claims of a few. Here, let us discuss an analogy that might serve in improving the understanding of how time works and draw parallels to the Eastern Philosophical thought which propounds certain properties to the fundamental nature of time.

Let us start with John Conway's Game of Life, then discuss how a computer processor works and see an example of a similar approach in Theoretical Physics research. Finally, we get to ask deep questions while pondering on the axioms set out by Eastern Philosophers. We shall also take multiple detours to address some other related aspects.

## Conway's Game of Life
We are starting with a complex system that is simple enough to study besides the fact that it has enough components for us to contemplate upon. John Conway, a famous mathematician(opinionated perhaps?), who worked on multifarious aspects of Math, developed a cellular automaton called Game of Life.

But first, what is a Cellular Automata? It is a model of a system with cell objects being its building blocks that follow some simple set of rules.

- These cells live on a **grid**.
- Each cell has a **state**. The number of state possibilities is typically finite. The simplest example has the two possibilities of 1 and 0.
- Each cell has a **neighbourhood**. This can be defined in any number of ways, but it is typically a list of adjacent cells.
- The cells in the grid interact and change their state according to some specific **rules** of the game. And the grid traverses the time in terms of **generations** by applying the rules to each cell present in the grid. Each generation represents the rules of the game applied to all the cells in the grid.

The development of cellular automata systems is typically attributed to Stanisław Ulam and John von Neumann, who were both researchers at the Los Alamos National Laboratory in New Mexico in the 1940s. Cellular Automata has its applications in a wide variety of fields, but let us keep ourselves to Game of Life which is a 2-D cellular automaton i.e, the grid is 2-D.

## Rules of the Game:


- **Death**. If a cell is alive (state = 1) it will die (state becomes 0) under the following circumstances.
Overpopulation: If the cell has four or more alive neighbours, it dies.
- **Loneliness**: If the cell has one or fewer alive neighbours, it dies.
- **Birth**. If a cell is dead (state = 0) it will come to life (state becomes 1) if it has exactly three alive neighbours (no more, no less).
- **Stasis**. In all other cases, the cell state does not change. To be thorough, let’s describe those scenarios.
Staying Alive: If a cell is alive and has exactly two or three live neighbours, it stays alive.
- **Staying Dead**: If a cell is dead and has anything other than three live neighbours, it stays dead.
Let's have a look at a few examples as shown below:


## Experiment Time
Here is a simple playground to experiment with the Game of Life.


{{<highlight text>}}
let w;
let columns;
let rows;
let board;
let next;

function setup() {
  createCanvas(854, 480);
  radio = createRadio();
  radio.option('Input');
  radio.option('Simulate');
  radio.option('Random');
  radio.option('Reset');
  radio.style('width', '400px');
  slider = createSlider(1, 255, 100);
  slider.position(10, 10);
  slider.style('width', '80px');
  w = 10;
  // Calculate columns and rows
  columns = floor(width / w);
  rows = floor(height / w);
  // Wacky way to make a 2D array is JS
  board = new Array(columns);
  for (let i = 0; i < columns; i++) {
    board[i] = new Array(rows);
  }
  // Going to use multiple 2D arrays and swap them
  next = new Array(columns);
  for (i = 0; i < columns; i++) {
    next[i] = new Array(rows);
  }
  init();
}

function draw() {
  clear();
  let val = radio.value();
  
  let val2 = slider.value();
  frameRate(val2);
  
  if(val == 'Simulate') {
    generate();
    for ( let i = 0; i < columns;i++) {
      for ( let j = 0; j < rows;j++) {
        if ((board[i][j] == 1)) fill(0);
        else fill(255);
        stroke(0);
        rect(i * w, j * w, w-1, w-1);
      }
    }
  }
  if(val == 'Random') {
    generate();
    for ( let i = 0; i < columns;i++) {
      for ( let j = 0; j < rows;j++) {
        if ((board[i][j] == 1)) fill(0);
        else fill(255);
        stroke(0);
        rect(i * w, j * w, w-1, w-1);
      }
    }
  }
  if(val == 'Input') {
    background(255);
    for ( let i = 0; i < columns;i++) {
      for ( let j = 0; j < rows;j++) {
        if ((board[i][j] == 1)) fill(0);
        else fill(255);
        stroke(0);
        rect(i * w, j * w, w-1, w-1);
      }
    }
  }
  
  if(val == 'Reset') {
    for ( let i = 0; i < columns;i++) {
      for ( let j = 0; j < rows;j++) {
        board[i][j] = 0;
      }
    }
    background(255);
    for ( let i = 0; i < columns;i++) {
      for ( let j = 0; j < rows;j++) {
        if ((board[i][j] == 1)) fill(0);
        else fill(255);
        stroke(0);
        rect(i * w, j * w, w-1, w-1);
      }
    }
  }
}

function mousePressed() {
  let val = radio.value();
  if(val == 'Random'){
    init();
  }
  if(val == 'Input') {
    stroke(0);
    board[parseInt(mouseX / 10)][parseInt(mouseY / 10)] = 1;
  }
}

// Fill board randomly
function init() {
  let val = radio.value();
  for (let i = 0; i < columns; i++) {
    for (let j = 0; j < rows; j++) {
      // Lining the edges with 0s
      if (i == 0 || j == 0 || i == columns-1 || j == rows-1) board[i][j] = 0;
      // Filling the rest randomly
      
      else {
        if(val == 'Random') {
          board[i][j] = floor(random(2));
        }
      }
      next[i][j] = 0;
    }
  }
}

// The process of creating the new generation
function generate() {

  // Loop through every spot in our 2D array and check spots neighbors
  for (let x = 1; x < columns - 1; x++) {
    for (let y = 1; y < rows - 1; y++) {
      // Add up all the states in a 3x3 surrounding grid
      let neighbors = 0;
      for (let i = -1; i <= 1; i++) {
        for (let j = -1; j <= 1; j++) {
          neighbors += board[x+i][y+j];
        }
      }

      // A little trick to subtract the current cell's state since
      // we added it in the above loop
      neighbors -= board[x][y];
      // Rules of Life
      if      ((board[x][y] == 1) && (neighbors <  2)) next[x][y] = 0;           // Loneliness
      else if ((board[x][y] == 1) && (neighbors >  3)) next[x][y] = 0;           // Overpopulation
      else if ((board[x][y] == 0) && (neighbors == 3)) next[x][y] = 1;           // Reproduction
      else                                             next[x][y] = board[x][y]; // Stasis
    }
  }

  // Swap!
  let temp = board;
  board = next;
  next = temp;
}
{{</highlight>}}



`<iframe src="https://ashwinbalaji0811.github.io/game-of-life/" width="870" height="530" style="border:1px solid black;"></iframe>`

You can run this program by pasting it here in the editor provided by `p5.js` to meet the dependencies of the above code. [`p5.js` Editor](https://editor.p5js.org/)

- The **input** option will take input from us for an **initial state** of the cells in the grid.
- The **simulate** option helps to traverse the generation using the game rules.
- The **Random** option generates an initial state using pseudo-random number generators and starts the simulation for us automatically.
- The **Reset** option helps to clean the slate for us to start afresh simulation.
- The **slider** in the top left corner helps you to speed up or slow down the simulation runtime. The extreme left will display a generation for a second before switching to the newer generation, the extreme right will switch 255 generations in a second, so feel free to adjust the slider for your comfort.

IF something appears broken, clicking it again might make it work. This is a run-of-the-mill program (with no optimizations) written using the `p5.js` Javascript library for a quick reference.

Here is the source code if you are interested in modifying it or changing the world size to a bigger one. To change the world size, just change the parameters of the `createCanvas(854, 480);` function at the top of the file. As you can see, the current simulation is running in **480p** resolution but has approximately 4100 cells. Increasing the resolution will increase the cell number which you have to do with caution as your CPU might be overloaded and you might experience a browser crash.

## Observations
Now, let us look at some undiscussed basis upon which this cellular automaton works. Time is represented as the counting of generations and our loops implement the laws of the world on every iteration. Hence, time is mapped as a counting function here.

Another observation is, we have some emergent phenomena from the seemingly simple rules of this world. We have static, oscillator, movement and generator figures popping up based on these simple laws of the world.

The above image represents possible shapes that stay the same as generations progress (or time progresses).

The above image shows us the oscillatory shapes with different periods. [This page](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life?ref=ashwin-balaji#Examples_of_patterns) shows more collections. How fascinating that a periodic structure should emerge from such simple concepts!




The above image patterns make a movement w.r.t every generational increment. Actually, nothing is moving according to automata but it appears to be moving from the top view; we could call it an abstraction.

Where are we going with these observations? We see an atmosphere where living, death, migration, reproduction and other complex mechanisms become emergent from simple rules of a checkerboard world which doesn't discuss such things in the first place.

Another observation is, the laws and the space is given to this world. They constitute the world and their interaction emerge more phenomena. The word interaction here is the key, we will get back to this point in the later section of this article.

This discussion can also lead to Turing machines and their related interesting phenomena, more on that in a future article.