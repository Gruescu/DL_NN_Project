import dlib
import cv2
from collections import deque
from statistics import mode

def main():
    detector = dlib.get_frontal_face_detector()
    predictor = dlib.shape_predictor("shape_predictor_68_face_landmarks.dat")

    cap = cv2.VideoCapture(0)
    cv2.namedWindow("Emotions Live", cv2.WINDOW_NORMAL)

    # Ultimele 5 predicții pentru stabilizare
    recent_emotions = deque(maxlen=5)

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        frame = cv2.resize(frame, (640, 480))
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        faces = detector(gray, 0)

        detected_emotion = "Detecting..."

        for face in faces:
            landmarks = predictor(gray, face)
            points = [(landmarks.part(i).x, landmarks.part(i).y) for i in range(68)]

            for x, y in points:
                cv2.circle(frame, (x, y), 1, (0, 255, 0), -1)

            try:
                ref_length = points[9][1] - points[28][1]
                if ref_length <= 0:
                    continue

                mouth_open = (points[58][1] - points[52][1]) / ref_length
                eye_openness = (points[42][1] - points[38][1]) / ref_length

                if mouth_open > 0.28:
                    detected_emotion = "Happy Face"
                elif mouth_open < 0.22 and eye_openness < 0.085:
                    detected_emotion = "Angry Face"
                else:
                    detected_emotion = "Neutral Face"

                recent_emotions.append(detected_emotion)
                stable_emotion = mode(recent_emotions)

                cv2.putText(frame, stable_emotion, (10, 40), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 0, 255), 2)

            except Exception as e:
                print("Eroare:", e)

        cv2.imshow("Emotions Live", frame)

        key = cv2.waitKey(1)
        if key == 27 or cv2.getWindowProperty("Emotions Live", cv2.WND_PROP_VISIBLE) < 1:
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == '__main__':
    main()
