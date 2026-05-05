package com.example.studentproject.service;

import com.example.studentproject.entity.Student;
import com.example.studentproject.entity.User;
import com.example.studentproject.repository.StudentRepository;
import com.example.studentproject.repository.UserRepository;
import org.springframework.stereotype.Service;

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

        User saved = userRepo.save(user);

        // AUTO STUDENT CREATE
        if (studentRepo.findFirstByEmail(user.getEmail()) == null) {
            Student s = new Student();
            s.setName(user.getUsername());
            s.setEmail(user.getEmail());
            s.setDepartment("Not Set");

            studentRepo.save(s);
        }

        return saved;
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

    return user;
}
}