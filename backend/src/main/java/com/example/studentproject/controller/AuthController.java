package com.example.studentproject.controller;

import com.example.studentproject.entity.User;
import com.example.studentproject.service.UserService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
@CrossOrigin("*")
public class AuthController {

    private final UserService service;

    public AuthController(UserService service) {
        this.service = service;
    }

    @PostMapping("/register")
    public User register(@RequestBody User user) {
        return service.register(user);
    }

@PostMapping("/login")
public User login(@RequestBody User user) {
    return service.loginByEmail(user.getEmail(), user.getPassword());
}
    
}