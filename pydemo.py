from flask import Flask, request, jsonify
import cv2
import numpy as np
import imutils
import easyocr
app = Flask(__name__)

@app.route('/recognize',methods=["GET","POST"])
def recognize_license_plate():
      imagePath = request.form.get('imagePath')
      print(imagePath)
      img = cv2.imread('4.png')
      gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
      bfilter = cv2.bilateralFilter(gray, 11, 17, 17) #Noise reduction
      edged = cv2.Canny(bfilter, 30, 200) #Edge detection
      keypoints = cv2.findContours(edged.copy(), cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
      contours = imutils.grab_contours(keypoints)
      contours = sorted(contours, key=cv2.contourArea, reverse=True)[:10]
      location = None
      for contour in contours:
        approx = cv2.approxPolyDP(contour, 10, True)
        if len(approx) == 4:
            location = approx
            break
      mask = np.zeros(gray.shape, np.uint8)
      new_image = cv2.drawContours(mask, [location], 0, 255, -1)
      new_image = cv2.bitwise_and(img, img, mask=mask)
      (x, y) = np.where(mask==255)
      (x1, y1) = (np.min(x), np.min(y))
      (x2, y2) = (np.max(x), np.max(y))
      cropped_image = gray[x1:x2+1, y1:y2+1]
      reader = easyocr.Reader(['en'])
      result = reader.readtext(cropped_image)
    # return result[0][1]
      return jsonify({'numberPlate' : result[0][1]})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
    
