-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 07, 2026 at 12:19 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `iecms`
--

-- --------------------------------------------------------

--
-- Table structure for table `assistants`
--

CREATE TABLE `assistants` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(150) NOT NULL,
  `role` varchar(50) DEFAULT 'Assistant',
  `status` varchar(20) DEFAULT 'offline',
  `completed` int(11) DEFAULT 0,
  `pending` int(11) DEFAULT 0,
  `phone` varchar(30) DEFAULT NULL,
  `whatsapp` varchar(30) DEFAULT NULL,
  `disabledAt` varchar(100) DEFAULT NULL,
  `disableDuration` varchar(100) DEFAULT NULL,
  `disableReason` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `assistants`
--

INSERT INTO `assistants` (`id`, `name`, `email`, `role`, `status`, `completed`, `pending`, `phone`, `whatsapp`, `disabledAt`, `disableDuration`, `disableReason`) VALUES
(1, 'Takunda Mutizwa', 'takundat364@gmail.com', 'Admin', 'online', 12, 4, '+263771111111', '+263771111111', NULL, NULL, NULL),
(4, 'Bob Nyabinde', 'bob@example.com', 'supervisor', 'online', 0, 4, '23346789889', '7678964333', '2026-09-18T05:59:46.516Z', '1', 'not available on leave'),
(5, 'Ashley Mutizwa', 'ashleymutizwa@gmail.com', 'assistant', 'online', 0, 1, '677565544234', '67778634323', NULL, NULL, NULL),
(6, 'Takunda Tanya', 'tapiwa234@gmail.com', 'assistant', 'offline', 0, 0, '+263714999796', '+263714999796', NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `general_users`
--

CREATE TABLE `general_users` (
  `id` int(11) NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `national_id` varchar(50) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `passkey_hash` varchar(255) DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `status` enum('active','suspended','blocked') DEFAULT 'active',
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `general_users`
--

INSERT INTO `general_users` (`id`, `full_name`, `national_id`, `email`, `password_hash`, `passkey_hash`, `phone`, `status`, `created_at`, `updated_at`) VALUES
(5, 'Takunda Locaa', '1234573S12', NULL, NULL, '$2y$10$9FLnq1NTxFSah.YgBWTmCOHFyZ6IS3s69yoL8ZMImvjQxdjCQDcAC', NULL, 'active', '2026-10-05 11:50:00', '2026-10-05 11:50:00');

-- --------------------------------------------------------

--
-- Table structure for table `general_user_passkeys`
--

CREATE TABLE `general_user_passkeys` (
  `id` int(11) NOT NULL,
  `general_user_id` int(11) NOT NULL,
  `credential_id` varbinary(255) NOT NULL,
  `public_key` text NOT NULL,
  `sign_count` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `monthly_reports`
--

CREATE TABLE `monthly_reports` (
  `report_month` char(7) NOT NULL,
  `sent_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` varchar(50) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `type` varchar(50) DEFAULT 'info',
  `is_read` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `title`, `message`, `user_id`, `created_at`, `type`, `is_read`) VALUES
('ticket_T-0D20E22E_pending_fb7894', 'Assignment Pending', 'Ticket T-0D20E22E is now Pending.', 1, '2026-10-05 15:08:40', 'info', 1),
('ticket_T-299958F2_pending_1a2af0', 'Assignment Pending', 'Ticket T-299958F2 is now Pending.', 3, '2026-10-06 08:44:26', 'info', 1),
('ticket_T-299958F2_resolved_5b29cc', 'Assignment Resolved', 'Ticket T-299958F2 is now Resolved.', 3, '2026-10-06 10:10:45', 'success', 1),
('ticket_T-2DDDD845_pending_6c7dc4', 'Assignment Pending', 'Ticket T-2DDDD845 is now Pending.', 2, '2026-10-06 08:30:57', 'info', 1),
('ticket_T-2DDDD845_resolved_7bd665', 'Assignment Resolved', 'Ticket T-2DDDD845 is now Resolved.', 2, '2026-10-06 08:32:52', 'success', 1),
('ticket_T-2_in_progress_2baa60', 'Assignment In Progress', 'Ticket T-2 is now In Progress.', 3, '2026-10-02 12:50:08', 'info', 1),
('ticket_T-2_pending_f9b917', 'Assignment Pending', 'Ticket T-2 is now Pending.', 3, '2026-10-02 12:49:15', 'info', 1),
('ticket_T-3284643F_pending_ed2a57', 'Assignment Pending', 'Ticket T-3284643F is now Pending.', 2, '2026-10-06 08:33:33', 'info', 1),
('ticket_T-43522E01_pending_c5c42f', 'Assignment Pending', 'Ticket T-43522E01 is now Pending.', 2, '2026-10-06 08:33:38', 'info', 1),
('ticket_T-47343C2D_pending_5afc2b', 'Assignment Pending', 'Ticket T-47343C2D is now Pending.', 3, '2026-10-06 08:47:31', 'info', 1),
('ticket_T-47343C2D_resolved_319bb0', 'Assignment Resolved', 'Ticket T-47343C2D is now Resolved.', 3, '2026-10-06 10:10:46', 'success', 1),
('ticket_T-49D4CDA0_in_progress_9b4778', 'Assignment In Progress', 'Ticket T-49D4CDA0 is now In Progress.', 3, '2026-10-05 15:20:33', 'info', 1),
('ticket_T-49D4CDA0_pending_61c2b0', 'Assignment Pending', 'Ticket T-49D4CDA0 is now Pending.', 3, '2026-10-02 12:59:13', 'info', 1),
('ticket_T-4C8362A9_pending_7e4124', 'Assignment Pending', 'Ticket T-4C8362A9 is now Pending.', 3, '2026-10-06 08:44:57', 'info', 1),
('ticket_T-4C8362A9_resolved_b48175', 'Assignment Resolved', 'Ticket T-4C8362A9 is now Resolved.', 3, '2026-10-06 10:10:42', 'success', 1),
('ticket_T-52534159_in_progress_05ba90', 'Assignment In Progress', 'Ticket T-52534159 is now In Progress.', 3, '2026-10-02 13:15:21', 'info', 1),
('ticket_T-52534159_pending_a409ad', 'Assignment Pending', 'Ticket T-52534159 is now Pending.', 3, '2026-10-02 12:56:47', 'info', 1),
('ticket_T-52534159_resolved_991324', 'Assignment Resolved', 'Ticket T-52534159 is now Resolved.', 3, '2026-10-06 10:10:31', 'success', 1),
('ticket_T-5E9669A9_pending_c1dacc', 'Assignment Pending', 'Ticket T-5E9669A9 is now Pending.', 3, '2026-10-06 08:44:23', 'info', 1),
('ticket_T-696D238C_in_progress_af91ed', 'Assignment In Progress', 'Ticket T-696D238C is now In Progress.', 3, '2026-10-02 13:11:20', 'info', 1),
('ticket_T-696D238C_pending_2fd7c3', 'Assignment Pending', 'Ticket T-696D238C is now Pending.', 3, '2026-10-02 12:59:20', 'info', 1),
('ticket_T-6BB68135_in_progress_1bd141', 'Assignment In Progress', 'Ticket T-6BB68135 is now In Progress.', 3, '2026-10-02 13:11:21', 'info', 1),
('ticket_T-6BB68135_pending_626f46', 'Assignment Pending', 'Ticket T-6BB68135 is now Pending.', 3, '2026-10-02 12:56:55', 'info', 1),
('ticket_T-6CDB535F_pending_681a8b', 'Assignment Pending', 'Ticket T-6CDB535F is now Pending.', 3, '2026-10-06 08:45:02', 'info', 1),
('ticket_T-6EAABCDF_pending_861e23', 'Assignment Pending', 'Ticket T-6EAABCDF is now Pending.', 3, '2026-10-06 08:47:14', 'info', 1),
('ticket_T-6EAABCDF_resolved_94e523', 'Assignment Resolved', 'Ticket T-6EAABCDF is now Resolved.', 3, '2026-10-06 10:10:47', 'success', 1),
('ticket_T-70945B28_pending_7d3ee9', 'Assignment Pending', 'Ticket T-70945B28 is now Pending.', 3, '2026-10-06 08:48:22', 'info', 1),
('ticket_T-71680A40_pending_ff14d4', 'Assignment Pending', 'Ticket T-71680A40 is now Pending.', 3, '2026-10-02 12:58:51', 'info', 1),
('ticket_T-80552A6A_pending_bc8bbf', 'Assignment Pending', 'Ticket T-80552A6A is now Pending.', 3, '2026-10-06 08:44:36', 'info', 1),
('ticket_T-80552A6A_resolved_5d8e44', 'Assignment Resolved', 'Ticket T-80552A6A is now Resolved.', 3, '2026-10-06 10:10:49', 'success', 1),
('ticket_T-8E309A1B_in_progress_c8e565', 'Assignment In Progress', 'Ticket T-8E309A1B is now In Progress.', 3, '2026-10-06 08:21:59', 'info', 1),
('ticket_T-8E309A1B_pending_92d61d', 'Assignment Pending', 'Ticket T-8E309A1B is now Pending.', 3, '2026-10-02 12:56:44', 'info', 1),
('ticket_T-8EF8547B_pending_e17ecb', 'Assignment Pending', 'Ticket T-8EF8547B is now Pending.', 3, '2026-10-02 12:56:51', 'info', 1),
('ticket_T-AB0BFEFD_in_progress_125f0b', 'Assignment In Progress', 'Ticket T-AB0BFEFD is now In Progress.', 2, '2026-09-17 14:08:56', 'info', 1),
('ticket_T-AB0BFEFD_in_progress_352012', 'Assignment In Progress', 'Ticket T-AB0BFEFD is now In Progress.', 2, '2026-09-17 14:09:01', 'info', 1),
('ticket_T-AB0BFEFD_in_progress_8a609f', 'Assignment In Progress', 'Ticket T-AB0BFEFD is now In Progress.', 2, '2026-09-17 14:09:06', 'info', 1),
('ticket_T-AB0BFEFD_in_progress_8d5b95', 'Assignment In Progress', 'Ticket T-AB0BFEFD is now In Progress.', 2, '2026-09-17 14:09:03', 'info', 1),
('ticket_T-AB0BFEFD_in_progress_b32993', 'Assignment In Progress', 'Ticket T-AB0BFEFD is now In Progress.', 2, '2026-09-17 14:08:58', 'info', 1),
('ticket_T-AB0BFEFD_in_progress_dd4025', 'Assignment In Progress', 'Ticket T-AB0BFEFD is now In Progress.', 2, '2026-09-17 14:09:07', 'info', 1),
('ticket_T-AB0BFEFD_pending_bc95ba', 'Assignment Pending', 'Ticket T-AB0BFEFD is now Pending.', 2, '2026-09-17 14:09:02', 'info', 1),
('ticket_T-AB0BFEFD_pending_dcd78c', 'Assignment Pending', 'Ticket T-AB0BFEFD is now Pending.', 2, '2026-09-17 14:09:06', 'info', 1),
('ticket_T-AB0BFEFD_pending_e7b0d3', 'Assignment Pending', 'Ticket T-AB0BFEFD is now Pending.', 2, '2026-09-17 14:08:57', 'info', 1),
('ticket_T-AB0BFEFD_resolved_3add78', 'Assignment Resolved', 'Ticket T-AB0BFEFD is now Resolved.', 2, '2026-09-17 14:08:28', 'success', 1),
('ticket_T-AB0BFEFD_resolved_5e7406', 'Assignment Resolved', 'Ticket T-AB0BFEFD is now Resolved.', 2, '2026-09-17 14:09:04', 'success', 1),
('ticket_T-AB0BFEFD_resolved_c3d6e6', 'Assignment Resolved', 'Ticket T-AB0BFEFD is now Resolved.', 2, '2026-09-17 14:08:59', 'success', 1),
('ticket_T-AE5704DE_pending_eb3042', 'Assignment Pending', 'Ticket T-AE5704DE is now Pending.', 3, '2026-10-06 08:44:54', 'info', 1),
('ticket_T-AE5704DE_resolved_9cc2cc', 'Assignment Resolved', 'Ticket T-AE5704DE is now Resolved.', 3, '2026-10-06 10:10:51', 'success', 1),
('ticket_T-B2CBA610_pending_e32aac', 'Assignment Pending', 'Ticket T-B2CBA610 is now Pending.', 2, '2026-10-06 08:33:26', 'info', 1),
('ticket_T-CF7AA0C9_pending_17281d', 'Assignment Pending', 'Ticket T-CF7AA0C9 is now Pending.', 3, '2026-10-06 08:44:32', 'info', 1),
('ticket_T-D47D16FD_pending_6ab7c1', 'Assignment Pending', 'Ticket T-D47D16FD is now Pending.', 3, '2026-10-06 08:44:49', 'info', 1),
('ticket_T-D525CFB0_pending_265a64', 'Assignment Pending', 'Ticket T-D525CFB0 is now Pending.', 3, '2026-10-06 08:44:40', 'info', 1),
('ticket_T-DB37D145_pending_6938b0', 'Assignment Pending', 'Ticket T-DB37D145 is now Pending.', 2, '2026-10-05 15:19:52', 'info', 1),
('ticket_T-DB37D145_resolved_243de9', 'Assignment Resolved', 'Ticket T-DB37D145 is now Resolved.', 2, '2026-10-05 15:22:26', 'success', 1),
('ticket_T-F51ACC49_pending_6264d0', 'Assignment Pending', 'Ticket T-F51ACC49 is now Pending.', 2, '2026-10-06 08:32:26', 'info', 1),
('ticket_T-F6B6EB18_pending_47d521', 'Assignment Pending', 'Ticket T-F6B6EB18 is now Pending.', 3, '2026-10-06 08:47:39', 'info', 1),
('ticket_T-FF2B379D_pending_701396', 'Assignment Pending', 'Ticket T-FF2B379D is now Pending.', 3, '2026-10-06 08:44:44', 'info', 1),
('ticket_TUPH1/26_pending_d739ce', 'Assignment Pending', 'Ticket TUPH1/26 is now Pending.', 1, '2026-10-06 12:02:10', 'info', 1);

-- --------------------------------------------------------

--
-- Table structure for table `tickets`
--

CREATE TABLE `tickets` (
  `id` varchar(20) NOT NULL,
  `date` varchar(100) NOT NULL,
  `assignedDate` varchar(100) DEFAULT NULL,
  `resolvedDate` varchar(100) DEFAULT NULL,
  `type` varchar(100) NOT NULL,
  `category` varchar(100) DEFAULT NULL,
  `description` text NOT NULL,
  `assignee` int(11) DEFAULT NULL,
  `status` enum('Pending','In Progress','Resolved') NOT NULL DEFAULT 'Pending',
  `external` varchar(255) DEFAULT NULL,
  `externalCause` varchar(255) DEFAULT NULL,
  `adminConstraint` varchar(255) DEFAULT NULL,
  `quantity` int(11) DEFAULT 1,
  `staffDetails` text DEFAULT NULL,
  `overdueNotified` tinyint(1) DEFAULT 0,
  `edited_by` varchar(255) DEFAULT NULL,
  `edited_at` datetime DEFAULT NULL,
  `reassigned_by` varchar(255) DEFAULT NULL,
  `reassigned_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `full_name` varchar(255) DEFAULT NULL,
  `email` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('admin','supervisor','assistant') NOT NULL DEFAULT 'assistant',
  `is_permanent_block` tinyint(1) DEFAULT 0,
  `failed_attempts` int(11) DEFAULT 0,
  `blocked_until` datetime DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `whatsapp` varchar(20) DEFAULT NULL,
  `last_login` datetime DEFAULT NULL,
  `last_activity` datetime DEFAULT NULL,
  `last_logout` datetime DEFAULT NULL,
  `last_login_alert` tinyint(1) DEFAULT 0,
  `reset_token` varchar(255) DEFAULT NULL,
  `reset_token_expiry` datetime DEFAULT NULL,
  `last_password_change` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `full_name`, `email`, `password_hash`, `role`, `is_permanent_block`, `failed_attempts`, `blocked_until`, `phone`, `whatsapp`, `last_login`, `last_activity`, `last_logout`, `last_login_alert`, `reset_token`, `reset_token_expiry`, `last_password_change`, `created_at`, `updated_at`) VALUES
(1, 'Takunda Mutizwa', 'takundat364@gmail.com', '$2y$10$IzecVVefL0/vUvc9zwFGY.Lpfq1XC55tdR4Oo2LMlSMLUh8pdNlHu', 'admin', 0, 0, NULL, NULL, NULL, '2026-10-07 12:01:10', '2026-10-07 12:01:11', '2026-10-07 10:20:41', 0, '708cb56923674f4e9531836aa02ef052a2c8ce1dfbd3364217c5d9e7591db896', '2026-10-07 08:55:59', NULL, '2026-01-08 16:04:32', '2026-10-07 12:01:11'),
(2, 'Bob Nyabinde', 'bob@example.com', '$2y$10$IzecVVefL0/vUvc9zwFGY.Lpfq1XC55tdR4Oo2LMlSMLUh8pdNlHu', 'supervisor', 0, 0, NULL, NULL, NULL, '2026-10-07 10:19:50', '2026-10-07 12:10:52', '2026-10-07 10:19:47', NULL, NULL, NULL, NULL, '2026-01-08 16:04:32', '2026-10-07 12:10:52'),
(3, 'Ashley Mutizwa', 'ashleymutizwa@gmail.com', '$2y$10$IzecVVefL0/vUvc9zwFGY.Lpfq1XC55tdR4Oo2LMlSMLUh8pdNlHu', 'assistant', 0, 0, NULL, NULL, NULL, '2026-10-07 10:20:17', '2026-10-07 10:44:53', '2026-10-07 10:19:58', 127, '0', NULL, NULL, '2026-01-08 16:04:32', '2026-10-07 10:44:53'),
(4, 'Takunda Tanya', 'tapiwa234@gmail.com', '$2y$10$9oJW2xwVg2NIK4HuCwjfFOpGN7e1DSUp/F5OSelvXOQe8M8/t9TVi', 'assistant', 0, 0, NULL, '+263714999796', '+263714999796', NULL, NULL, NULL, 0, NULL, NULL, NULL, '2026-10-06 11:06:38', '2026-10-06 11:06:38');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `assistants`
--
ALTER TABLE `assistants`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_assistants_role` (`role`);

--
-- Indexes for table `general_users`
--
ALTER TABLE `general_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `uq_general_users_national_id` (`national_id`);

--
-- Indexes for table `general_user_passkeys`
--
ALTER TABLE `general_user_passkeys`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `credential_id` (`credential_id`),
  ADD KEY `general_user_id` (`general_user_id`);

--
-- Indexes for table `monthly_reports`
--
ALTER TABLE `monthly_reports`
  ADD PRIMARY KEY (`report_month`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_notifications_user` (`user_id`);

--
-- Indexes for table `tickets`
--
ALTER TABLE `tickets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_tickets_assignee` (`assignee`),
  ADD KEY `idx_tickets_assignee_status` (`assignee`,`status`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `assistants`
--
ALTER TABLE `assistants`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `general_users`
--
ALTER TABLE `general_users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `general_user_passkeys`
--
ALTER TABLE `general_user_passkeys`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `general_user_passkeys`
--
ALTER TABLE `general_user_passkeys`
  ADD CONSTRAINT `general_user_passkeys_ibfk_1` FOREIGN KEY (`general_user_id`) REFERENCES `general_users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `tickets`
--
ALTER TABLE `tickets`
  ADD CONSTRAINT `fk_tickets_assignee` FOREIGN KEY (`assignee`) REFERENCES `assistants` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
