import { HttpClient, HttpErrorResponse, HttpHeaders } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { catchError, throwError } from "rxjs";
import { AuthService } from "../account-forms/services/auth.service";

export class Message {
  /**
   *
   */
  constructor(
    public messageId: number = 0,
    public senderId: number = 0,
    public reciverId: number = 0,
    public contactFirstName: string = '',
    public contactLastName: string = '',
    public message: string = '',
    public recived: boolean = false,
    public sentAt: Date = new Date()
  ) { }
}
class Contact {
  /**
   *
   */
  constructor(
    public id: number,
    public name: string,
    public profileImgUrl: string,
    public lastMessage: string
  ) { }
}

@Injectable()
export class MessageService {

  constructor(
    private http: HttpClient,
    private authService: AuthService
  ) { }

  currentUserId = this.authService.getUserDetails()[0].member_id;
  rootURL = '/api';
  httpOptions = {
    headers: new HttpHeaders({
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${this.authService.getToken()}`
    })
  };

  getMessages(userId: number = this.currentUserId, contactId: number) {
    return this.http.get<[Message]>(this.rootURL + '/messages/' + userId + '/' + contactId, this.httpOptions)
      .pipe(
        catchError(this.handleError)
      );
  }

  insertMessages(message: Message) {
    return this.http.post<object>(this.rootURL + '/post-message', message, this.httpOptions)
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
