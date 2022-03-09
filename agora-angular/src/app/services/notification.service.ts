import { HttpClient, HttpErrorResponse, HttpHeaders } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { catchError, throwError } from "rxjs";
import { Auth } from "./auth";

export interface Notification {
    notificationId: number,
    senderId: number,
    senderFirstName: string,
    senderLastName: string,
    reciverId: number,
    content: string,
    type: string,
    itemId: number,
    link: string,
    seen: boolean,
    sentAt: Date
}

export class Notification {
    /**
     *
     */
    constructor(
        public notificationId: number = 0,
        public senderId: number = 0,
        public senderFirstName: string = "",
        public senderLastName: string = "",
        public reciverId: number = 0,
        public content: string = "",
        public type: string = "",
        public itemId: number = 0,
        public link: string = "",
        public seen: boolean = false,
        public sentAt: Date = new Date()
    ) {
    }
}

@Injectable()
export class NotificationService {

    constructor(private http: HttpClient) { }
    currentUser = Auth.currentUser;
    rootURL = '/api';

    getNotifications( userId: number = this.currentUser.userId) {
        return this.http.get<[Notification]>(this.rootURL + '/notifications/' + userId,)
            .pipe(
                catchError(this.handleError)
            );
    }


    private handleError(error: HttpErrorResponse) {
        if (error.status === 0) {
            // A client-side or network error occurred. Handle it accordingly.
            console.error('An error occurred:', error.error);
        } else {
            // The backend returned an unsuccessful response code.
            // The response body may contain clues as to what went wrong.
            console.error(
                `Backend returned code ${error.status}, body was: `, error.error);
        }
        // Return an observable with a user-facing error message.
        return throwError(() =>
            'Something bad happened; please try again later.');
    }

}