-- ============================================================
-- FreeCodeLMS Database Schema
-- PostgreSQL
-- ============================================================

-- ============================================================
-- USERS
-- ============================================================

CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    profile_image VARCHAR(500),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- ROLES
-- ============================================================

CREATE TABLE roles (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- ============================================================
-- USER ROLES
-- ============================================================

CREATE TABLE user_roles (
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,

    PRIMARY KEY (user_id, role_id),

    CONSTRAINT fk_user_roles_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_user_roles_role
        FOREIGN KEY (role_id)
        REFERENCES roles(id)
        ON DELETE CASCADE
);

-- ============================================================
-- COURSES
-- ============================================================

CREATE TABLE courses (
    id BIGSERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    thumbnail VARCHAR(500),
    level VARCHAR(50),
    language VARCHAR(50),
    status VARCHAR(30) NOT NULL DEFAULT 'DRAFT',
    created_by BIGINT NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_courses_creator
        FOREIGN KEY (created_by)
        REFERENCES users(id)
);

-- ============================================================
-- MODULES
-- ============================================================

CREATE TABLE modules (
    id BIGSERIAL PRIMARY KEY,
    course_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    display_order INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT fk_modules_course
        FOREIGN KEY (course_id)
        REFERENCES courses(id)
        ON DELETE CASCADE
);

-- ============================================================
-- LESSONS
-- ============================================================

CREATE TABLE lessons (
    id BIGSERIAL PRIMARY KEY,
    module_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    content TEXT,
    display_order INTEGER NOT NULL DEFAULT 0,
    duration_minutes INTEGER,
    status VARCHAR(30) NOT NULL DEFAULT 'DRAFT',

    CONSTRAINT fk_lessons_module
        FOREIGN KEY (module_id)
        REFERENCES modules(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_lesson_slug_per_module
        UNIQUE (module_id, slug)
);

-- ============================================================
-- VIDEOS
-- ============================================================

CREATE TABLE videos (
    id BIGSERIAL PRIMARY KEY,
    lesson_id BIGINT NOT NULL,
    youtube_video_id VARCHAR(50) NOT NULL,
    title VARCHAR(255),
    duration_seconds INTEGER,

    CONSTRAINT fk_videos_lesson
        FOREIGN KEY (lesson_id)
        REFERENCES lessons(id)
        ON DELETE CASCADE
);

-- ============================================================
-- ENROLLMENTS
-- ============================================================

CREATE TABLE enrollments (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    course_id BIGINT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    enrolled_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMPTZ,

    CONSTRAINT fk_enrollments_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_enrollments_course
        FOREIGN KEY (course_id)
        REFERENCES courses(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_user_course
        UNIQUE (user_id, course_id)
);

-- ============================================================
-- QUIZZES
-- ============================================================

CREATE TABLE quizzes (
    id BIGSERIAL PRIMARY KEY,
    lesson_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    passing_score NUMERIC(5,2) NOT NULL DEFAULT 60.00,
    max_attempts INTEGER,

    CONSTRAINT fk_quizzes_lesson
        FOREIGN KEY (lesson_id)
        REFERENCES lessons(id)
        ON DELETE CASCADE
);

-- ============================================================
-- QUESTIONS
-- ============================================================

CREATE TABLE questions (
    id BIGSERIAL PRIMARY KEY,
    quiz_id BIGINT NOT NULL,
    question_text TEXT NOT NULL,
    question_type VARCHAR(30) NOT NULL DEFAULT 'MULTIPLE_CHOICE',
    points NUMERIC(5,2) NOT NULL DEFAULT 1.00,
    display_order INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT fk_questions_quiz
        FOREIGN KEY (quiz_id)
        REFERENCES quizzes(id)
        ON DELETE CASCADE
);

-- ============================================================
-- ANSWERS
-- ============================================================

CREATE TABLE answers (
    id BIGSERIAL PRIMARY KEY,
    question_id BIGINT NOT NULL,
    answer_text TEXT NOT NULL,
    is_correct BOOLEAN NOT NULL DEFAULT FALSE,
    display_order INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT fk_answers_question
        FOREIGN KEY (question_id)
        REFERENCES questions(id)
        ON DELETE CASCADE
);

-- ============================================================
-- QUIZ ATTEMPTS
-- ============================================================

CREATE TABLE quiz_attempts (
    id BIGSERIAL PRIMARY KEY,
    quiz_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    score NUMERIC(5,2),
    passed BOOLEAN,
    started_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMPTZ,

    CONSTRAINT fk_quiz_attempts_quiz
        FOREIGN KEY (quiz_id)
        REFERENCES quizzes(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_quiz_attempts_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

-- ============================================================
-- CODING EXERCISES
-- ============================================================

CREATE TABLE coding_exercises (
    id BIGSERIAL PRIMARY KEY,
    lesson_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    language VARCHAR(50) NOT NULL,
    starter_code TEXT,
    difficulty VARCHAR(30),
    time_limit_ms INTEGER DEFAULT 2000,
    memory_limit_mb INTEGER DEFAULT 128,

    CONSTRAINT fk_coding_exercises_lesson
        FOREIGN KEY (lesson_id)
        REFERENCES lessons(id)
        ON DELETE CASCADE
);

-- ============================================================
-- TEST CASES
-- ============================================================

CREATE TABLE test_cases (
    id BIGSERIAL PRIMARY KEY,
    exercise_id BIGINT NOT NULL,
    input_data TEXT,
    expected_output TEXT NOT NULL,
    is_hidden BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT fk_test_cases_exercise
        FOREIGN KEY (exercise_id)
        REFERENCES coding_exercises(id)
        ON DELETE CASCADE
);

-- ============================================================
-- SUBMISSIONS
-- ============================================================

CREATE TABLE submissions (
    id BIGSERIAL PRIMARY KEY,
    exercise_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    source_code TEXT NOT NULL,
    language VARCHAR(50) NOT NULL,
    status VARCHAR(30),
    score NUMERIC(5,2),
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_submissions_exercise
        FOREIGN KEY (exercise_id)
        REFERENCES coding_exercises(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_submissions_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE
);

-- ============================================================
-- LESSON PROGRESS
-- ============================================================

CREATE TABLE lesson_progress (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    lesson_id BIGINT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'NOT_STARTED',
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,

    CONSTRAINT fk_lesson_progress_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_lesson_progress_lesson
        FOREIGN KEY (lesson_id)
        REFERENCES lessons(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_user_lesson_progress
        UNIQUE (user_id, lesson_id)
);

-- ============================================================
-- CERTIFICATES
-- ============================================================

CREATE TABLE certificates (
    id BIGSERIAL PRIMARY KEY,
    certificate_number VARCHAR(100) NOT NULL UNIQUE,
    verification_code VARCHAR(100) NOT NULL UNIQUE,
    user_id BIGINT NOT NULL,
    course_id BIGINT NOT NULL,
    completion_score NUMERIC(5,2),
    issue_date DATE NOT NULL DEFAULT CURRENT_DATE,
    pdf_url VARCHAR(500),

    CONSTRAINT fk_certificates_user
        FOREIGN KEY (user_id)
        REFERENCES users(id),

    CONSTRAINT fk_certificates_course
        FOREIGN KEY (course_id)
        REFERENCES courses(id)
);

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_courses_created_by
    ON courses(created_by);

CREATE INDEX idx_modules_course_id
    ON modules(course_id);

CREATE INDEX idx_lessons_module_id
    ON lessons(module_id);

CREATE INDEX idx_videos_lesson_id
    ON videos(lesson_id);

CREATE INDEX idx_enrollments_user_id
    ON enrollments(user_id);

CREATE INDEX idx_enrollments_course_id
    ON enrollments(course_id);

CREATE INDEX idx_quizzes_lesson_id
    ON quizzes(lesson_id);

CREATE INDEX idx_questions_quiz_id
    ON questions(quiz_id);

CREATE INDEX idx_quiz_attempts_user_id
    ON quiz_attempts(user_id);

CREATE INDEX idx_submissions_user_id
    ON submissions(user_id);

CREATE INDEX idx_lesson_progress_user_id
    ON lesson_progress(user_id);

CREATE INDEX idx_certificates_user_id
    ON certificates(user_id);