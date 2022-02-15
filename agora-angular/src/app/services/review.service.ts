import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { HttpErrorResponse, HttpResponse } from '@angular/common/http';
import { catchError, Observable, throwError } from 'rxjs';
import { Auth } from './auth';

export interface Review {
    reviewId: number,
    userId: number,
    userFirstName: string,
    userLastName: string,
    title: string,
    content: string,
    rating: number,
    points: number,
    publishedAt: Date
}

export class Review {
    /**
     *
     */
    constructor(
        public reviewId: number = 0,
        public userId: number = 0,
        public userFirstName: string = "",
        public userLastName: string = "",
        public title: string = "",
        public content: string = "",
        public rating: number = -1,
        public points: number = -1,
        public publishedAt: Date = new Date()
    ) {
    }
}

@Injectable()
export class ReviewService {

    constructor(private http: HttpClient) { }

    currentUser = Auth.currentUser;

    rootURL = '/api';

    getReview(id: number): Observable<Review> {
        return this.http.get<Review>(this.rootURL + '/review/' + id)
            .pipe(
                catchError(error => this.handleError(error))
            );
    }

    postReview(review: Review) {
        return this.http.post<object>(this.rootURL + '/post-review', review)
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

