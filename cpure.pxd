from libcpp cimport bool

cdef extern from "stdlib.h":
    ctypedef unsigned long size_t
    void free(void *ptr)
    void *malloc(size_t size)
    void *realloc(void *ptr, size_t size)
    size_t strlen(char *s)
    void *calloc(long nmemb, long size)

cdef extern from "string.h":
    char *strcpy(char *dest, char *src)

cdef extern from "stdint.h":
    ctypedef int int32_t
    ctypedef int uint32_t

cdef extern from "stdarg.h":
    ctypedef struct va_list:
        pass
    ctypedef struct fake_type:
        pass
    void va_start(va_list, void* arg)
    void* va_arg(va_list, fake_type)
    void va_end(va_list)
    fake_type expr_type "pure_expr*"

# This is a complete wrapping of the public api located in
# /usr/include/pure/runtime.h though only a small part of it is
# used in the Python interface.

cdef extern from "pure/runtime.h":
    ctypedef struct pure_expr:
        int32_t tag
        uint32_t refc

    ctypedef struct pure_interp:
        pass

    pure_interp *pure_create_interp(int argc, char *argv[])
    char *str(pure_expr *x)

    #Constructors
    int32_t pure_sym(char *s)
    pure_expr *pure_symbol(int32_t sym)
    pure_expr *pure_symbolx(int32_t sym, pure_expr **e)
    pure_expr *pure_quoted_symbol(int32_t tag)
    pure_expr *pure_int(int32_t i)
    #pure_expr *pure_mpz(mpz_t z)
    pure_expr *pure_double(double d)
    pure_expr *pure_pointer(void *p)
    pure_expr *pure_expr_pointer()

    #String handling
    pure_expr *pure_string_dup(char *s)
    pure_expr *pure_cstring_dup(char *s)
    pure_expr *pure_string(char *s)
    pure_expr *pure_cstring(char *s)

    #Matrix constructors
    pure_expr *pure_symbolic_matrix(void *p)
    pure_expr *pure_double_matrix(void *p)
    pure_expr *pure_complex_matrix(void *p)
    pure_expr *pure_int_matrix(void *p)
    pure_expr *pure_symbolic_matrix_dup(void *p)
    pure_expr *pure_double_matrix_dup(void *p)
    pure_expr *pure_complex_matrix_dup(void *p)
    pure_expr *pure_int_matrix_dup(void *p)

    #Matrix handling
    pure_expr *pure_matrix_rowsl(uint32_t n, ...)
    pure_expr *pure_matrix_rowsv(uint32_t n, pure_expr **elems)
    pure_expr *pure_matrix_columnsl(uint32_t n, ...)
    pure_expr *pure_matrix_columnsv(uint32_t n, pure_expr **elems)

    #Function calls
    pure_expr *pure_funcall(void *f, uint32_t n, ...)
    pure_expr *pure_funcallx(void *f, pure_expr **e, uint32_t n, ...)

    #Function applications
    pure_expr *pure_app(pure_expr *fun, pure_expr *arg)
    pure_expr *pure_appl(pure_expr *fun, size_t argc, ...)
    pure_expr *pure_appv(pure_expr *fun, size_t argc, pure_expr **args)
    pure_expr *pure_appx(pure_expr *fun, pure_expr *arg, pure_expr **e)
    pure_expr *pure_appxl(pure_expr *fun, pure_expr **e, size_t argc, ...)
    pure_expr *pure_appxv(pure_expr *fun, size_t argc, pure_expr **args, pure_expr **e)
    pure_expr *pure_applc(pure_expr *x, pure_expr *y)

    #List handling
    pure_expr *pure_listl(size_t size, ...)
    pure_expr *pure_listv(size_t size, pure_expr **elems)
    pure_expr *pure_listv2(size_t size, pure_expr **elems, pure_expr *tail)
    pure_expr *pure_tuplel(size_t size, ...)
    pure_expr *pure_tuplev(size_t size, pure_expr **elems)
    pure_expr *pure_listlq(size_t size, ...)
    pure_expr *pure_listvq(size_t size, pure_expr **elems)
    pure_expr *pure_listv2q(size_t size, pure_expr **elems, pure_expr *tail)
    pure_expr *pure_tuplelq(size_t size, ...)
    pure_expr *pure_tuplevq(size_t size, pure_expr **elems)
    pure_expr *pure_intlistv(size_t size, int32_t *elems)
    pure_expr *pure_intlistv2(size_t size, int32_t *elems, pure_expr *tail)
    pure_expr *pure_inttuplev(size_t size, int32_t *elems)
    pure_expr *pure_doublelistv(size_t size, double *elems)
    pure_expr *pure_doublelistv2(size_t size, double *elems, pure_expr *tail)
    pure_expr *pure_doubletuplev(size_t size, double *elems)
    pure_expr *pure_intlistvq(size_t size, int32_t *elems)
    pure_expr *pure_intlistv2q(size_t size, int32_t *elems, pure_expr *tail)
    pure_expr *pure_inttuplevq(size_t size, int32_t *elems)
    pure_expr *pure_doublelistvq(size_t size, double *elems)
    pure_expr *pure_doublelistv2q(size_t size, double *elems, pure_expr *tail)
    pure_expr *pure_doubletuplevq(size_t size, double *elems)

    pure_expr *pure_complex(double c[2])
    #pure_expr *pure_rationalz(mpz_t z[2])

    #Type testing
    bool pure_is_symbol(pure_expr *x, int32_t *sym)
    bool pure_is_int(pure_expr *x, int32_t *i)
    #bool pure_is_mpz(pure_expr *x, mpz_t *z)
    bool pure_is_double(pure_expr *x, double *d)
    bool pure_is_pointer(pure_expr *x, void **p)
    bool pure_is_string(pure_expr *x, char **s)
    bool pure_is_string_dup(pure_expr *x, char **s)
    bool pure_is_cstring_dup(pure_expr *x, char **s)

    bool pure_is_symbolic_matrix(pure_expr *x, void **p)
    bool pure_is_double_matrix(pure_expr *x, void **p)
    bool pure_is_complex_matrix(pure_expr *x, void **p)
    bool pure_is_int_matrix(pure_expr *x, void **p)
    bool pure_is_app(pure_expr *x, pure_expr **fun, pure_expr **arg)
    bool pure_is_appv(pure_expr *x, pure_expr **fun, size_t *argc, pure_expr ***args)
    bool pure_is_listv(pure_expr *x, size_t *size, pure_expr ***elems)
    bool pure_is_tuplev(pure_expr *x, size_t *size, pure_expr ***elems)
    bool pure_is_complex(pure_expr *x, double *c)
    #bool pure_is_rationalz(pure_expr *x, mpz_t *z)

    #Memory Management
    pure_expr *pure_new(pure_expr *x)
    void pure_free(pure_expr *x)
    void pure_freenew(pure_expr *x)
    void pure_ref(pure_expr *x)
    void pure_unref(pure_expr *x)
    void pure_interp_compile(pure_interp *interp, int32_t fno)

    pure_expr *pure_sentry(pure_expr *sentry, pure_expr *x)
    pure_expr *pure_get_sentry(pure_expr *x)
    pure_expr *pure_clear_sentry(pure_expr *x)

    pure_expr *pure_val(char *s)
    pure_expr *reduce(pure_expr *lcls, pure_expr *x)

    pure_expr *eval(pure_expr *x)
    pure_expr *evalcmd(pure_expr *x)
    pure_expr *pure_locals(uint32_t n, ...)

    pure_expr *pure_eval(char *s)
    pure_expr *pure_evalx(pure_expr *x, pure_expr** e)
    char *pure_evalcmd(char *s)

    bool pure_let(int32_t sym, pure_expr *x)
    bool pure_def(int32_t sym, pure_expr *x)

    #Level handling
    uint32_t pure_save()
    uint32_t pure_savelevel()
    uint32_t pure_restore()

    bool pure_clear(int32_t sym)

    uint32_t hash(pure_expr *x)
    bool same(pure_expr *x, pure_expr *y)
