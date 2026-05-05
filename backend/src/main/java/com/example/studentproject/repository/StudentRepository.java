package com.example.studentproject.repository;

import com.example.studentproject.entity.Student;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface StudentRepository extends JpaRepository<Student, Long> {
    Student findFirstByEmail(String email);
    List<Student> findAllByEmail(String email);
}