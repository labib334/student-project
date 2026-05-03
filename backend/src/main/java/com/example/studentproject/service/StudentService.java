package com.example.studentproject.service;

import com.example.studentproject.entity.Course;
import com.example.studentproject.entity.Student;
import com.example.studentproject.repository.CourseRepository;
import com.example.studentproject.repository.StudentRepository;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.List;

@Service
public class StudentService {

    private final StudentRepository studentRepo;
    private final CourseRepository courseRepo;

    public StudentService(StudentRepository studentRepo, CourseRepository courseRepo) {
        this.studentRepo = studentRepo;
        this.courseRepo = courseRepo;
    }

    public Student create(Student s) {
        return studentRepo.save(s);
    }

    public List<Student> getAll() {
        return studentRepo.findAll();
    }

    public Student assign(Long sid, Long cid) {

        Student student = studentRepo.findById(sid).orElseThrow();
        Course course = courseRepo.findById(cid).orElseThrow();

        if (student.getCourses() == null) {
            student.setCourses(new HashSet<>());
        }

        student.getCourses().add(course);

        return studentRepo.save(student);
    }
}