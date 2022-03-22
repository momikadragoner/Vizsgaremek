import { HttpClient, HttpErrorResponse, HttpHeaders } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { catchError, throwError } from "rxjs";
import { AuthService, } from "../account-forms/services/auth.service";

@Injectable()
export class FollowService {

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

  postFollow(userId: number) {
    let follow = {
      "follower": this.currentUserId,
      "following": userId
    }
    return this.http.post<object>(this.rootURL + '/post-follow', follow, this.httpOptions)
      .pipe(
        catchError(error => this.handleError(error))
      );
  }

  deleteFollow(followingId: number) {
    return this.http.delete(this.rootURL + '/delete-follow/' + this.currentUserId + '/' + followingId, this.httpOptions)
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
