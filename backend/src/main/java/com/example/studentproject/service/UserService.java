package com.example.studentproject.service;

import com.example.studentproject.entity.User;
import com.example.studentproject.repository.UserRepository;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    private final UserRepository repo;

    public UserService(UserRepository repo) {
        this.repo = repo;
    }

    public User register(User user) {
        return repo.save(user);
    }

    public User login(String username, String password) {
        User user = repo.findByUsername(username);

        if (user == null || !user.getPassword().equals(password)) {
            throw new RuntimeException("Invalid login");
        }

        return user;
    }
}