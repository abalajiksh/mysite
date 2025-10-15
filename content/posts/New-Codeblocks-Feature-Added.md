+++
date = '2025-10-15T17:40:08+02:00'
draft = false
title = 'New Codeblocks Feature Added'
useAlpine = false
loadNerdFont = true
tags = []
+++

## The Past

Old codeblocks used to look something like this

![](/images/code-block-issue.png)

It had 2 glaring problems:

1. It doesn't look great, but functional.
2. The copy icon slides with the scrollbar.

So, I went ahead to fix the issue. 

## Present

I took the help of Claude to add this feature, because, lets face it, I am no good when it comes to CSS and Javascript. After a few hours of tinkering around, here are the results:

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <memory>

// Modern C++ with templates and smart pointers
template<typename T>
class Container {
private:
    std::vector<std::unique_ptr<T>> data;

public:
    void add(T&& item) {
        data.push_back(std::make_unique<T>(std::move(item)));
    }

    void process() {
        std::for_each(data.begin(), data.end(), 
            [](const auto& ptr) { 
                std::cout << *ptr << '\n'; 
            });
    }
};
```

```mathematica
(* Solve a differential equation *)
solution = DSolve[y''[x] + 2*y'[x] + y[x] == 0, y[x], x]

(* Create a parametric plot with styling *)
ParametricPlot3D[
  {Cos[t], Sin[t], t/4}, {t, 0, 8 Pi},
  PlotStyle -> Directive[Thick, Orange],
  ColorFunction -> Function[{x, y, z}, Hue[z]],
  PlotPoints -> 100
]

(* Matrix operations *)
mat = {{1, 2}, {3, 4}};
{eigenvalues, eigenvectors} = Eigensystem[mat]
```

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;

    # SSL configuration
    ssl_certificate /etc/ssl/certs/example.com.crt;
    ssl_certificate_key /etc/ssl/private/example.com.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    location / {
        root /var/www/html;
        try_files $uri $uri/ =404;
    }
    
    # Reverse proxy for API
    location /api/ {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

```bash
#!/bin/bash

# Backup script with error handling
BACKUP_DIR="/var/backups"
SOURCE_DIR="/home/user/data"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup with compression
create_backup() {
    local dest="${BACKUP_DIR}/backup_${DATE}.tar.gz"
    
    if tar -czf "$dest" -C "$SOURCE_DIR" .; then
        echo "Backup created: $dest"
        # Keep only last 7 backups
        find "$BACKUP_DIR" -name "backup_*.tar.gz" -mtime +7 -delete
    else
        echo "Backup failed!" >&2
        return 1
    fi
}

create_backup
```

```rs
use std::fs::File;
use std::io::{self, Read};

enum Status {
    Active,
    Inactive,
    Suspended,
}

// Error handling with Result and the ? operator
fn read_config(path: &str) -> io::Result<String> {
    let mut file = File::open(path)?;
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;
    Ok(contents)
}

// Pattern matching with enums
fn check_status(status: Status) -> &'static str {
    match status {
        Status::Active => "User is active",
        Status::Inactive => "User is inactive",
        Status::Suspended => "Account suspended",
    }
}
```

```go
package main

import (
    "context"
    "fmt"
    "time"
)

// Worker processes jobs with context cancellation
func worker(ctx context.Context, id int, jobs <-chan int, results chan<- int) {
    for {
        select {
        case <-ctx.Done():
            fmt.Printf("Worker %d stopping\n", id)
            return
        case job := <-jobs:
            // Simulate work
            time.Sleep(100 * time.Millisecond)
            results <- job * 2
        }
    }
}
```




~~Now, I have wrecked all the old articles by bringing about this change. I will have to go through every one of them and modify it to unwreck the wreckage I have brought forth.~~ Nevermind, fixed most of them.