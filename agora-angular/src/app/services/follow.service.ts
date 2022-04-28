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

  currentUserId() {
    return this.authService.getUserDetails()[0].member_id
  }
  rootURL = '/api';

  postFollow(userId: number) {
    let follow = {
      "follower": this.currentUserId(),
      "following": userId
    }
    return this.http.post<object>(this.rootURL + '/follow', follow, { headers: new HttpHeaders({ 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.authService.getToken()}` })})
      .pipe(
        catchError(error => this.handleError(error))
      );
  }

  deleteFollow(followingId: number) {
    return this.http.delete(this.rootURL + '/follow/' + this.currentUserId() + '/' + followingId, { headers: new HttpHeaders({ 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.authService.getToken()}` })})
      .pipe(
        catchError(this.handleError)
      );
  }

  private handleError(error: HttpErrorResponse) {
    if (error.status === 0) {
      console.error('An error occurred:', error.error);
    } else {
      console.error(
        `Backend returned code ${error.status}, body was: `, error.error);
    }
    return throwError(() =>
      'Something bad happened; please try again later.');
  }

}
