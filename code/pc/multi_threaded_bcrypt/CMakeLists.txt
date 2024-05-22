cmake_minimum_required(VERSION 2.6.0)
    
project(bcrypt_multicore C)

add_executable(${PROJECT_NAME} main.c)

target_link_libraries(${PROJECT_NAME} PUBLIC
    crypt
)