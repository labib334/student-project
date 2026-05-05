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

    public List<Student> getAll() {
        return studentRepo.findAll();
    }

    public Student create(Student s) {
        if (s.getEmail() != null) {
            Student existing = studentRepo.findFirstByEmail(s.getEmail());
            if (existing != null) {
                existing.setName(s.getName());
                existing.setAge(s.getAge());
                existing.setDepartment(s.getDepartment());
                return studentRepo.save(existing);
            }
        }
        return studentRepo.save(s);
    }

    public Student getByEmail(String email) {
        return studentRepo.findFirstByEmail(email);
    }

    public Student assign(Long sid, Long cid) {

        Student student = studentRepo.findById(sid).orElseThrow();
        Course course = courseRepo.findById(cid).orElseThrow();

        if (student.getCourses() == null) {
            student.setCourses(new HashSet<>());
        }

        student.getCourses().add(course);

        // 🔥 BOTH SIDE UPDATE (VERY IMPORTANT)
        if (course.getStudents() == null) {
            course.setStudents(new HashSet<>());
        }

        course.getStudents().add(student);

        courseRepo.save(course);      // 🔥 MUST
        return studentRepo.save(student);
    }

    public void delete(Long id) {
        Student student = studentRepo.findById(id).orElseThrow();

        if (student.getCourses() != null) {
            student.getCourses().clear();
        }

        studentRepo.delete(student);
    }
}