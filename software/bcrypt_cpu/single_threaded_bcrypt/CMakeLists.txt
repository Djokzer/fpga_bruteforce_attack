cmake_minimum_required(VERSION 2.6.0)
    
project(test_bcrypt C)

add_executable(${PROJECT_NAME} main.c)

target_link_libraries(${PROJECT_NAME} PUBLIC
    crypt
)