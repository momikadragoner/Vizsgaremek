import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { HttpErrorResponse, HttpResponse } from '@angular/common/http';
import { catchError, Observable, throwError } from 'rxjs';
import { AuthService } from '../account-forms/services/auth.service';

export interface Review {
  reviewId: number,
  userId: number,
  productId: number,
  userFirstName: string,
  userLastName: string,
  title: string,
  content: string,
  rating: number,
  points?: number,
  publishedAt: Date,
  myVote?: string
}

export class Review {
  /**
   *
   */
  constructor(
    public reviewId: number = 0,
    public userId: number = 0,
    public productId: number = 0,
    public userFirstName: string = "",
    public userLastName: string = "",
    public title: string = "",
    public content: string = "",
    public rating: number = -1,
    public points?: number,
    public publishedAt: Date = new Date(),
    public myVote?: string
  ) {
  }
}

export class ReviewVote {
  constructor(
    public reviewVoteId: number = 0,
    public productId: number = 0,
    public reviewId: number = 0,
    public userId: number = 0,
    public votedAt: Date = new Date(),
    public vote?: string
  ) {

  }
}

@Injectable()
export class ReviewService {

  constructor(
    private http: HttpClient,
    private authService: AuthService
  ) { }

  currentUserId() {
    return this.authService.getUserDetails()[0].member_id
  }
  isLoggedIn() {
    if (this.authService.getUserDetails()[0].member_id) {
      return true;
    }
    else {
      return false;
    }
  }
  rootURL = '/api';

  getReview(id: number): Observable<Review> {
    let url = this.isLoggedIn() ? this.rootURL + '/review/' + id + "/auth/" + this.currentUserId() : this.rootURL + '/review/' + id;
    return this.http.get<Review>(url, {
      headers: new HttpHeaders({
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.authService.getToken()}`
      })
    })
      .pipe(
        catchError(error => this.handleError(error))
      );
  }

  postReview(review: Review) {
    return this.http.post<object>(this.rootURL + '/review', review, {
      headers: new HttpHeaders({
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.authService.getToken()}`
      })
    })
      .pipe(
        catchError(error => this.handleError(error))
      );
  }

  deleteReview(id: number) {
    return this.http.delete(this.rootURL + '/delete-review/' + id)
      .pipe(
        catchError(this.handleError)
      );
  }

  postReviewVote(reviewVote:ReviewVote) {
    return this.http.post<object>(this.rootURL + '/review-vote', reviewVote, {
      headers: new HttpHeaders({
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.authService.getToken()}`
      })
    })
      .pipe(
        catchError(error => this.handleError(error))
      );
  }

  deleteReviewVote(reviewId: number, userId:number = this.currentUserId()) {
    return this.http.delete(this.rootURL + '/review-vote/' + reviewId + '/' + userId, {
      headers: new HttpHeaders({
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.authService.getToken()}`
      })
    })
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

