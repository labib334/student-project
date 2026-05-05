package com.example.studentproject.service;

import com.example.studentproject.entity.Student;
import com.example.studentproject.entity.User;
import com.example.studentproject.repository.StudentRepository;
import com.example.studentproject.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class UserService {

    private final UserRepository userRepo;
    private final StudentRepository studentRepo;

    public UserService(UserRepository userRepo, StudentRepository studentRepo) {
        this.userRepo = userRepo;
        this.studentRepo = studentRepo;
    }

    public User register(User user) {

        if (userRepo.findByEmail(user.getEmail()) != null)
            throw new RuntimeException("Email already exists");

        user.setRole("USER");

        return userRepo.save(user);
    }

    public User loginByEmail(String email, String password) {

        System.out.println("EMAIL FROM FRONTEND: " + email); // 🔥 debug

        if (email == null || email.isEmpty()) {
            throw new RuntimeException("Email is null");
        }

        User user = userRepo.findByEmail(email); // ❗ MUST be userRepo

        if (user == null) {
            throw new RuntimeException("User not found in DB");
        }

        if (!user.getPassword().equals(password)) {
            throw new RuntimeException("Wrong password");
        }

        if ("USER".equals(user.getRole())) {
            Student existing = studentRepo.findFirstByEmail(user.getEmail());
            if (existing == null) {
                Student s = new Student();
                s.setName(user.getUsername());
                s.setEmail(user.getEmail());
                s.setDepartment("Not Set");
                studentRepo.save(s);
            }
        }

        return user;
    }

    public List<String> getAllUserEmails() {
        return userRepo.findAllByRole("USER")
                .stream()
                .map(User::getEmail)
                .collect(Collectors.toList());
    }
}
