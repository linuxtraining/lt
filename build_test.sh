#!/usr/bin/env bats

@test "Runnign without params" {
    ./make.sh 
        [ $? -eq 0 ]
}

@test "Building Fundamentals Book with 0 debug" {
    ./make.sh -d 0 build fundamentals 
        [ $? -eq 0 ]
}

@test "Building Fundamentals Book with 1 debug" {
    ./make.sh -d 1 build fundamentals 
        [ $? -eq 0 ]
}

@test "Building Fundamentals Book with 2 debug" {
    ./make.sh -d 0 build fundamentals 
        [ $? -eq 0 ]
}

@test "Building Fundamentals Book with 3 debug" {
    ./make.sh -d 3 build fundamentals 
        [ $? -eq 0 ]
}

@test "Building Fundamentals Book with 4 debug" {
    ./make.sh -d 4 build fundamentals 
        [ $? -eq 0 ]
}

@test "Building Complete Book with 0 debug" {
    ./make.sh -d 0 build complete 
        [ $? -eq 0 ]
}

@test "Building Complete Book with 1 debug" {
    ./make.sh -d 1 build complete 
        [ $? -eq 0 ]
}

@test "Building Complete Book with 2 debug" {
    ./make.sh -d 2 build complete 
        [ $? -eq 0 ]
}

@test "Building Complete Book with 3 debug" {
    ./make.sh -d 3 build complete 
        [ $? -eq 0 ]
}

@test "Building Complete Book with 4 debug" {
    ./make.sh -d 4 build complete 
        [ $? -eq 0 ]
}