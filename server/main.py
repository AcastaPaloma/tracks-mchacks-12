import cv2
import mediapipe as mp
import time
from collections import defaultdict

FACE_WIDTH = 12
TEST_WINDOW_TIME = 2
try:
    screen = get_monitors()[0]
    SCREEN_HEIGHT = screen.height
except:
    SCREEN_HEIGHT = 1080

class Chronometer:
    def __init__(self, handchrono):
        self.total_time = 0.0
        self.start_time = 0.0
        self.hc = handchrono
        self.hc.extrema_tracking['elapsed_time'] = 0.0
        self.hc.extrema_tracking['active'] = False

    def start(self):
        if not self.hc.extrema_tracking['active']:
            self.start_time = time.time()
            self.hc.extrema_tracking['active'] = True
            print("Setting start time to", self.start_time)

    def stop(self):
        if self.hc.extrema_tracking['active']:
            self.hc.extrema_tracking['elapsed_time'] = time.time() - self.start_time
            self.total_time += self.hc.extrema_tracking['elapsed_time']
            self.hc.extrema_tracking['active'] = False
            print("Setting elapsed_time ")

    def reset(self):
        self.total_time = 0.0
        self.start_time = 0.0
        self.hc.extrema_tracking['elapsed_time'] = 0.0
        self.hc.extrema_tracking['active'] = False

    @property
    def time(self):
        if self.hc.extrema_tracking['active']:
            return self.total_time + (time.time() - self.start_time)
        return self.total_time

class HandChronometer:
    def __init__(self):
        self.mp_hands = mp.solutions.hands
        self.mp_pose = mp.solutions.pose
        self.pose = self.mp_pose.Pose(min_detection_confidence=0.5, min_tracking_confidence=0.5)

        self.mp_drawing = mp.solutions.drawing_utils
        self.hands = self.mp_hands.Hands(
            static_image_mode=False, 
            max_num_hands=2, 
            min_detection_confidence=0.7, 
            min_tracking_confidence=0.7
        )
        self.last_action_time = 0
        self.action_cooldown = 2.0
        self.exercise_list = ["Curl", "Pushup", "Squat", "Lat Raise"]
        self.this_exercise_index = 0
        self.start_frame = 0
        self.stop_frame = 0
        
        self.extrema_tracking = {
            'active': False,
            'elapsed_time': 0,
            'max_y': float('-inf'),
            'min_y': float('inf')
        }
        self.chronometer = Chronometer(self)


    def fingers_up(self, hand_landmarks, handedness):
        tips = [4, 8, 12, 16, 20]
        count = 0

        if handedness == "Right":
            if hand_landmarks.landmark[tips[0]].x > hand_landmarks.landmark[tips[0] - 1].x:
                count += 1
        else:
            if hand_landmarks.landmark[tips[0]].x < hand_landmarks.landmark[tips[0] - 1].x:
                count += 1

        for tip in tips[1:]:
            if hand_landmarks.landmark[tip].y < hand_landmarks.landmark[tip - 2].y:
                count += 1

        return count

    def process_hand_action(self, finger_count, current_time, current_frame):
        if current_time - self.last_action_time >= 0.1 and current_time - self.last_action_time < self.action_cooldown:
            return
        
        FRAME_BUFFER = 100

        if finger_count - 1 == 2:  # Two fingers up
            if not self.extrema_tracking['active'] and current_frame >= self.stop_frame + FRAME_BUFFER:
                print("Two fingers detected. Activating.")
                self.chronometer.start()
                self.extrema_tracking['max_y'] = float('-inf')
                self.extrema_tracking['min_y'] = float('inf')
                self.last_action_time = current_time
                self.start_frame = current_frame
            elif self.chronometer.time >= 4 and current_frame >= self.start_frame + FRAME_BUFFER:
                self.chronometer.stop()
                print(f"Exercise {self.exercise_list[self.this_exercise_index]} Extrema:")
                print(f"Max Y: {self.extrema_tracking['max_y']}")
                print(f"Min Y: {self.extrema_tracking['min_y']}")
                self.extrema_tracking['max_y'] = float('-inf')
                self.extrema_tracking['min_y'] = float('inf')
                self.last_action_time = current_time
        elif finger_count - 1 == 3:  # Three fingers up
            self.chronometer.reset()
            self.this_exercise_index = (self.this_exercise_index + 1) % len(self.exercise_list)
            self.last_action_time = current_time

    def run(self):
        cap = cv2.VideoCapture(1)
        original_width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        original_height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        aspect_ratio = original_width / original_height

        new_height = min(SCREEN_HEIGHT - 100, 1920)
        new_width = int(new_height * aspect_ratio)

        current_frame = 0
        while cap.isOpened():
            current_frame += 1
            ret, frame = cap.read()
            if not ret:
                break

            frame = cv2.flip(frame, 1)
            h, w, _ = frame.shape
            current_time = time.time()  

            rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            hand_result = self.hands.process(rgb_frame)
            pose_result = self.pose.process(rgb_frame)

            pose_landmarks = pose_result.pose_landmarks

            time_text = f"Time: {self.chronometer.time:.2f} sec"
            cv2.putText(frame, time_text, (10, 50), 
                        cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)

            exercise_text = f"Exercise: {self.exercise_list[self.this_exercise_index]}"
            cv2.putText(frame, exercise_text, (10, 100), 
                        cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)

            if pose_landmarks and self.extrema_tracking['active']:
                self.mp_drawing.draw_landmarks(frame, pose_result.pose_landmarks, self.mp_pose.POSE_CONNECTIONS)
                right_ear = pose_landmarks.landmark[self.mp_pose.PoseLandmark.RIGHT_EAR.value]
                left_ear = pose_landmarks.landmark[self.mp_pose.PoseLandmark.LEFT_EAR.value]

                right_ear_x, right_ear_y = right_ear.x * new_width, right_ear.y * new_height
                left_ear_x, left_ear_y = left_ear.x * new_width, left_ear.y * new_height
                propConstant = FACE_WIDTH / (((right_ear_y - left_ear_y) ** 2 + (right_ear_x - left_ear_x) ** 2) ** 0.5)
                
                right_shoulder = pose_landmarks.landmark[self.mp_pose.PoseLandmark.RIGHT_SHOULDER.value]
                left_shoulder = pose_landmarks.landmark[self.mp_pose.PoseLandmark.LEFT_SHOULDER.value]
                
                right_shoulder_x, right_shoulder_y = right_shoulder.x * new_width, right_shoulder.y * new_height
                left_shoulder_x, left_shoulder_y = left_shoulder.x * new_width, left_shoulder.y * new_height
                
                avg_shoulder_y = ((right_shoulder_y + left_shoulder_y)/ 2) * propConstant
                self.extrema_tracking['max_y'] = max(self.extrema_tracking['max_y'], avg_shoulder_y)
                self.extrema_tracking['min_y'] = min(self.extrema_tracking['min_y'], avg_shoulder_y)

            if hand_result.multi_hand_landmarks:
                hand_landmarks, hand_handedness = hand_result.multi_hand_landmarks[0], hand_result.multi_handedness[0]
                # for hand_landmarks, hand_handedness in zip(hand_result.multi_hand_landmarks, hand_result.multi_handedness):
                handedness_label = hand_handedness.classification[0].label
                finger_count = self.fingers_up(hand_landmarks, handedness_label)

                self.process_hand_action(finger_count, current_time, current_frame)
                
                self.mp_drawing.draw_landmarks(frame, hand_landmarks, self.mp_hands.HAND_CONNECTIONS)

                x, y = int(hand_landmarks.landmark[0].x * w), int(hand_landmarks.landmark[0].y * h)
                cv2.putText(frame, f"{handedness_label}: {finger_count - 1} fingers", (x, y - 10),
                            cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)

            cv2.imshow('Hand Chronometer', frame)

            if cv2.waitKey(1) & 0xFF == ord('q'):
                break

        cap.release()
        cv2.destroyAllWindows()

def main():
    hand_chrono = HandChronometer()
    hand_chrono.run()

if __name__ == "__main__":
    main()